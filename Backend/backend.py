from PySide6.QtCore import QObject, Signal, Property, Slot, QStringListModel, QUrl

class Backend(QObject):
    deviceDiscovered = Signal(str, str)  # name, ip
    connectionStateChanged = Signal()
    connectionStateUpdated = Signal(str)

    activityStateChanged = Signal()
    activityStateUpdated = Signal(str)

    conRequest_Signal = Signal(str)
    packetReceived = Signal(str, str)
    sendPacket = Signal(str, str)
    sendData = Signal()

    # Receiving file state

    tcpStartServer = Signal()
    tcpConnectOnServer = Signal(str)

    deleteIndexes = Signal(list)

    model = QStringListModel()

    selectedFilesChanged = Signal()

    def __init__(self):
        super().__init__()
        self._connectionState = "idle"  # ⚠️ must exist
        self._fileState = "idle"  # ⚠️ must exist
        self._selectedFiles = []

    def getConnectionState(self):
        return self._connectionState

    def setConnectionState(self, state):
        if self._connectionState != state:
            self._connectionState = state
            print("State changed to:", state)
            self.connectionStateChanged.emit()
            self.connectionStateUpdated.emit(state)

    def getActivityState(self):
        return self._fileState

    @Slot(str)
    def setActivityState(self, state):
        if self._fileState != state:
            self._fileState = state
            print("File State changed to:", state)
            self.activityStateChanged.emit()
            self.activityStateUpdated.emit(state)

    def getSelectedFiles(self):
        return self._selectedFiles

    # ----- States -----

    connectionState = Property(
        str,
        getConnectionState,
        setConnectionState,
        notify=connectionStateChanged
    )

    activityState = Property(
        str,
        getActivityState,
        setActivityState,
        notify=activityStateChanged
    )

    selectedFiles = Property(
        list,
        getSelectedFiles,
        notify=selectedFilesChanged
    )

    # ----- Slots -----

    @Slot(str)
    def conRequest(self, ip: str):
        self.conRequest_Signal.emit(ip)

    @Slot(str, str)
    def onPacketReceived(self, ip: str, packet_type: str):
        print(f"DEBUG: Backend relaying {packet_type} from {ip}")
        self.packetReceived.emit(ip, packet_type)

    @Slot(str, str)
    def sendPacketSignal(self, ip: str, message: str):
        self.sendPacket.emit(ip, message)


    @Slot(list)
    def addSelectedFiles(self, files):
        paths = []
        for f in files:
            # Converts URL string ('file:///path/to/file') to native OS path ('/path/to/file')
            url = QUrl(f)
            if url.isLocalFile():
                paths.append(url.toLocalFile())
            else:
                paths.append(f)

        # 4. Update the array and notify everything listening in QML
        self._selectedFiles.extend(paths)
        print("Current file list in Python:", self._selectedFiles)
        self.selectedFilesChanged.emit()

    @Slot(list)
    def removeIndexes(self, filePaths):
        print("removeIndexes:", filePaths)
        for f in filePaths:
            self._selectedFiles.remove(f)

        self.selectedFilesChanged.emit()
