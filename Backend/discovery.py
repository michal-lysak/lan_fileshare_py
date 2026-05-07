# This Python file uses the following encoding: utf-8

from Backend import tcp_manager
from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtNetwork import QUdpSocket, QHostAddress
import socket
from Backend.tcp_manager import TCPManager


class DiscoveryWorker(QObject):
    deviceFound = Signal(str, str)  # name, ip
    stateChanged = Signal(str)
    packetReceived_Signal = Signal(str, str)
    packetSend_Signal = Signal(str)
    

    def __init__(self):
        
        super().__init__()
        self.socket = QUdpSocket(self)
        self.devices = set()

    def start(self):
        
        PORT = 9999
        # Bind UDP socket (Qt way)
        self.socket.bind(
            QHostAddress.Any,
            PORT,
            QUdpSocket.ShareAddress | QUdpSocket.ReuseAddressHint
        )

        self.socket.readyRead.connect(self.processPendingDatagrams)
        self.sendDiscovery()
        
        print("Listening for devices (QUdpSocket)...")


    def sendDiscovery(self):

        hostname = socket.gethostname()
        message = f"DISCOVER|{hostname}".encode()

        self.socket.writeDatagram(
            message,
            QHostAddress.Broadcast,
            9999
        )

        print("Broadcast sent:", message.decode())


    @Slot(str, str)
    def sendPacket(self, ip: str, message: str):
        print(message, ip)

        self.socket.writeDatagram(message.encode(), QHostAddress(ip), 9999)

    def conRequest(self, ip: str):
        hostname = socket.gethostname()
        message = f"CONNECT_REQUEST|{hostname}".encode()
        
        self.socket.writeDatagram(message, QHostAddress(ip), 9999)
        
    def processPendingDatagrams(self):
        while self.socket.hasPendingDatagrams():
            datagram, host, port = self.socket.readDatagram(
                self.socket.pendingDatagramSize()
            )

            message = datagram.data().decode()
            ip = host.toString()

            if message.startswith("DISCOVER"):
                parts = message.split("|")
                name = parts[1] if len(parts) > 1 else "Unknown"

                if ip not in self.devices:
                    self.devices.add(ip)
                    print(f"Found device: {name} -> {ip}")
                    self.deviceFound.emit(name, ip)

            elif message.startswith("CONNECT_"):
                print(f"Connection request from {ip}")

                packet_type = message.split("|")[0]
                self.packetReceived_Signal.emit(ip, packet_type)
