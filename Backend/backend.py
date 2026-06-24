from PySide6.QtCore import QFileInfo, QObject, Signal, Property, Slot, QUrl

from backend.models.FileListModel import FileListModel, FileRoles

class Backend(QObject):
    def __init__(self, fileModel):
        super().__init__()
        self._connectionState = "idle"
        self.fileModel = fileModel

    # UDP signals
    deviceDiscovered = Signal(str, str)  # name, ip

    # connection state signals
    connectionStateChanged = Signal()
    connectionStateUpdated = Signal(str)

    # activity state signals
    activityStateChanged = Signal()
    activityStateUpdated = Signal(str)

    # Network signals
    conRequest_Signal = Signal(str)
    packetReceived = Signal(str, str, str)
    sendPacket = Signal(str, str)
    sendData = Signal()
    
    # TCP signals
    tcpStartServer = Signal()
    tcpConnectOnServer = Signal(str)

    deleteFiles_Ids = Signal(list)

    # imported files signal
    selectedFilesChanged = Signal()


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
            self.activityStateChanged.emit()
            self.activityStateUpdated.emit(state)

   # def getSelectedFiles(self):
        #return self._importedFiles

    def manageIncomingFiles(self, filePaths):
        print("manageIncomingFiles called with:", filePaths)

        for filePath in filePaths:
            file = QFileInfo(filePath)
            file_size = file.size()
            file_name = file.fileName()

            print("about to add file:", file_name, "with size:", file_size, "and path:", filePath)

            self.fileModel.addFile(file_name, filePath, file_size, "incoming")


            #print("FROM MODEL:" + self.fileModel.data(filePath, FileRoles.NameRole))


    def onSelectedFilesChanged(self):
        return self.manageFiles(self._importedFiles)


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


    # ----- Slots -----

    @Slot(str)
    def conRequest(self, ip: str):
        self.conRequest_Signal.emit(ip)

    @Slot(str, str, str)
    def onPacketReceived(self, ip: str, packet_type: str, device_name: str):
        print(f"DEBUG: Backend relaying {packet_type} from {ip}")
        self.packetReceived.emit(ip, packet_type, device_name)

    @Slot(str, str)
    def sendPacketSignal(self, ip: str, message: str):
        self.sendPacket.emit(ip, message)


    @Slot(list)
    def addSelectedFiles(self, filePaths):
        # self.manageFiles(filePaths)
        
        print("manageFiles called with:", filePaths)
        for filePath in filePaths:
            filePathN = QUrl(filePath).toLocalFile() 
            file = QFileInfo(filePathN)
            file_size = file.size()
            file_name = file.fileName()
            direction = "outgoing"  

            print("about to add file:", file_name, "with size:", file_size, "and path:", filePath)

            self.fileModel.addFile(file_name, filePath, file_size, direction)


            #print("FROM MODEL:" + self.fileModel.data(filePath, FileRoles.NameRole))


    @Slot(list)
    def removeFiles_Ids(self, ids):
        print("removeIds:", ids)
        
        for id in ids:
            self.fileModel.removeFile(id)
            print("Removed file with id:", id)

        #self.selectedFilesChanged.emit()