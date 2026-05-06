from PySide6.QtCore import QObject, Signal, Property, Slot

class Backend(QObject):
    deviceDiscovered = Signal(str, str)  # name, ip
    connectionStateChanged = Signal()
    conRequest_Signal = Signal(str)
    packetReceived = Signal(str, str)

    def __init__(self):
        super().__init__()
        self._connectionState = "idle"  # ⚠️ must exist

    def getConnectionState(self):
        return self._connectionState

    def setConnectionState(self, state):
        if self._connectionState != state:
            self._connectionState = state
            print("State changed to:", state)
            self.connectionStateChanged.emit()

    connectionState = Property(
        str,
        getConnectionState,
        setConnectionState,
        notify=connectionStateChanged
    )

    @Slot(str)
    def conRequest(self, ip: str):
        self.conRequest_Signal.emit(ip)

    @Slot(str, str)
    def onPacketReceived(self, ip: str, packet_type: str):
        print(f"DEBUG: Backend relaying {packet_type} from {ip}")
        self.packetReceived.emit(ip, packet_type)
