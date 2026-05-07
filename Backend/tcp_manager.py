import os
from PySide6.QtCore import (QObject, QFile, QFileInfo, QDir, QStandardPaths,
                            QDataStream, QByteArray, QIODevice, QMimeDatabase, Slot)
from PySide6.QtNetwork import QTcpServer, QTcpSocket, QHostAddress
from PySide6.QtCore import QObject, Signal, Property, Slot
class TCPManager(QObject):
    def __init__(self, backend, parent=None):
        super().__init__(parent)
        self.m_backend = backend
        self.tcpServer = None
        self.tcpSocket = None
        self.m_clientSockets = []

        self.tcpStartServer = Signal(str)

        # Replaces the C++ 'static' variables used in onReadyRead
        self._reset_receive_state()

    def _reset_receive_state(self):
        """Helper to reset the state machine for file receiving."""
        self.expectedHeaderSize = -1
        self.currentHeader = {"fileName": "", "fileSize": 0, "created": None, "mimeType": ""}
        self.currentFile = None
        self.bytesReceived = 0

    def startServer(self):
        port = 45454
        print("TCP SERVER STARTING...")
        self.tcpServer = QTcpServer(self)
        self.tcpServer.newConnection.connect(self.onNewConnection)

        if not self.tcpServer.listen(QHostAddress.SpecialAddress.Any, port):
            print(f"Server could not start! Error: {self.tcpServer.errorString()}")
            return

        print(f"Server started on port {port}")

    def connectToHost(self, ip: str):
        # Assuming your StatusClass is accessible somehow in Python
        # if self.m_backend.connectionState() == StatusClass.TCP_CONNECTED:
        #     print("TCP: Another device tried connection, declined - already connected")
        #     return
        print("Trying to connect on server")
    
        port = 45454
        if not self.tcpSocket:
            self.tcpSocket = QTcpSocket(self)
            self.tcpSocket.readyRead.connect(self.onReadyRead)
            self.tcpSocket.disconnected.connect(self.onDisconnected)
            
            # Using a lambda/local function for the connected signal
            def on_connected():
                print("Connected to server!")
                # self.m_backend.setConnectionState(StatusClass.TCP_CONNECTED)
            
            self.tcpSocket.connected.connect(on_connected)

        self.tcpSocket.connectToHost(QHostAddress(ip), port)

    def sendData(self):
        print("Sending data...")
        # Assuming m_filesManager is a Python property/attribute on your backend
        files = self.m_backend.m_filesManager.m_selectedFiles
        for file_path in files:
            self.sendFile(file_path)

    # =======================
    # Sending side
    # =======================
    def sendFile(self, file_path: str):
        print(f"Sending file: {file_path}")

        if not self.tcpSocket or self.tcpSocket.state() != QTcpSocket.SocketState.ConnectedState:
            print("Not connected to any host.")
            return

        file = QFile(file_path)
        if not file.open(QIODevice.OpenModeFlag.ReadOnly):
            print(f"Failed to open file: {file_path}")
            return

        # Prepare FileHeader data
        file_info = QFileInfo(file_path)
        file_name = file_info.fileName()
        file_size = file.size()
        created = file_info.birthTime()
        mime_type = QMimeDatabase().mimeTypeForFile(file_info).name()

        # Serialize header
        header_block = QByteArray()
        header_stream = QDataStream(header_block, QIODevice.OpenModeFlag.WriteOnly)
        header_stream.setVersion(QDataStream.Version.Qt_6_9)
        
        # Explicitly write fields (Replaces C++ `headerStream << header;`)
        header_stream.writeString(file_name)
        header_stream.writeInt64(file_size)
        header_stream.writeQVariant(created) # QDateTime wraps well in QVariant
        header_stream.writeString(mime_type)

        # Send header size (int32)
        header_size = header_block.size()
        size_prefix = QByteArray()
        size_stream = QDataStream(size_prefix, QIODevice.OpenModeFlag.WriteOnly)
        size_stream.setVersion(QDataStream.Version.Qt_6_9)
        size_stream.writeInt32(header_size)

        self.tcpSocket.write(size_prefix)
        self.tcpSocket.write(header_block)

        # Send file data in chunks
        chunk_size = 64 * 1024
        while not file.atEnd():
            buffer = file.read(chunk_size)
            self.tcpSocket.write(buffer)

        file.close()
        print(f"File sent successfully: {file_name}")

    # =======================
    # Receiving side
    # =======================
    @Slot()
    def onNewConnection(self):
        if self.m_clientSockets:
            # Already have a client, reject the new connection
            new_socket = self.tcpServer.nextPendingConnection()
            print(f"Rejected new client from {new_socket.peerAddress().toString()} - already connected")
            new_socket.disconnectFromHost()
            new_socket.deleteLater()
            return

        client_socket = self.tcpServer.nextPendingConnection()
        client_socket.readyRead.connect(self.onReadyRead)
        client_socket.disconnected.connect(self.onDisconnected)

        self.m_clientSockets.append(client_socket)
        print(f"New client connected from {client_socket.peerAddress().toString()}")

    @Slot()
    def onReadyRead(self):
        socket = self.sender()
        if not socket:
            return

        in_stream = QDataStream(socket)
        in_stream.setVersion(QDataStream.Version.Qt_6_9)

        while True:
            # Step 1: Read header size (4 bytes for qint32)
            if self.expectedHeaderSize == -1:
                if socket.bytesAvailable() < 4: 
                    return  # wait for full size
                self.expectedHeaderSize = in_stream.readInt32()
                continue

            # Step 2: Read header block
            if not self.currentHeader["fileName"]:
                if socket.bytesAvailable() < self.expectedHeaderSize:
                    return  # wait for full header

                header_block = socket.read(self.expectedHeaderSize)
                header_stream = QDataStream(header_block, QIODevice.OpenModeFlag.ReadOnly)
                header_stream.setVersion(QDataStream.Version.Qt_6_9)

                # Deserialize header fields manually
                self.currentHeader["fileName"] = header_stream.readString()
                self.currentHeader["fileSize"] = header_stream.readInt64()
                self.currentHeader["created"] = header_stream.readQVariant() 
                self.currentHeader["mimeType"] = header_stream.readString()

                # Prepare file to save
                save_dir = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.DownloadLocation) + "/NearbyFiles/"
                QDir().mkpath(save_dir)
                
                save_path = os.path.join(save_dir, self.currentHeader["fileName"])
                
                self.currentFile = QFile(save_path)
                if not self.currentFile.open(QIODevice.OpenModeFlag.WriteOnly):
                    print(f"Failed to open file for writing: {save_path}")
                    self._reset_receive_state()
                    return

                self.bytesReceived = 0
                print(f"Receiving file: {self.currentHeader['fileName']} Size: {self.currentHeader['fileSize']}")
                continue

            # Step 3: Read file data
            if self.bytesReceived < self.currentHeader["fileSize"]:
                # Calculate remaining bytes to read, up to 64KB max
                remaining = self.currentHeader["fileSize"] - self.bytesReceived
                bytes_to_read = min(remaining, 64 * 1024)
                
                chunk = socket.read(bytes_to_read)
                self.currentFile.write(chunk)
                self.bytesReceived += chunk.size()

                if self.bytesReceived < self.currentHeader["fileSize"]:
                    return  # wait for more data

            # Step 4: File complete
            if self.bytesReceived >= self.currentHeader["fileSize"]:
                self.currentFile.close()
                print(f"✅ File received successfully: {self.currentHeader['fileName']}")
                
                # Reset state machine for the next potential file
                self._reset_receive_state()

    @Slot()
    def onDisconnected(self):
        # self.m_backend.setConnectionState(StatusClass.ConnectionState.TCP_DISCONNECTED)
        socket = self.sender()
        if not socket:
            return

        print(f"Client disconnected: {socket.peerAddress().toString()}")

        if socket in self.m_clientSockets:
            self.m_clientSockets.remove(socket)
        socket.deleteLater()