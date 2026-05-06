# This Python file uses the following encoding: utf-8
import sys
import resources_rc
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from Backend.backend import Backend
from Backend.discovery import DiscoveryWorker
from PySide6.QtCore import QThread, QObject, Signal


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"

    backend = Backend()

    worker = DiscoveryWorker()
    thread = QThread()

    worker.moveToThread(thread)
    thread.started.connect(worker.start)
    thread.started.connect(lambda: backend.setConnectionState("discovering"))

    worker.deviceFound.connect(backend.deviceDiscovered)
    worker.packetReceived_Signal.connect(backend.onPacketReceived)
    worker.stateChanged.connect(backend.setConnectionState)

    backend.conRequest_Signal.connect(worker.conRequest)

    thread.start()
    engine.rootContext().setContextProperty("backend", backend)

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
