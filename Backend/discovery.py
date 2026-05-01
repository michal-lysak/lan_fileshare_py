# This Python file uses the following encoding: utf-8

# if __name__ == "__main__":
#     pass

import socket
from PySide6.QtCore import QObject, Signal


class DiscoveryWorker(QObject):
    deviceFound = Signal(str, str)  # Signal to emit when a device is found
    
    def start(self):
        PORT = 9999

        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(("0.0.0.0", PORT))

        print("Listenning for devices...")

        devices = set()

        while True:
            data, addr = sock.recvfrom(1024)
            message = data.decode()

            if message.startswith("DISCOVER"):
                parts = message.split("|")
                name = parts[1] if len(parts) > 1 else "Unknown"


                if addr[0] not in devices:
                    devices.add(addr[0])
                    print(f"Found device: {name} -> {addr[0]}")

                    self.deviceFound.emit(name, addr[0])

class Backend(QObject):
    deviceDiscovered = Signal(str, str) #name, ip

    def __init__(self):
        super().__init__()