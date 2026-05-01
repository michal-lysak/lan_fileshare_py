# This Python file uses the following encoding: utf-8
import sys
import resources_rc
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from Backend.discovery import DiscoveryWorker, Backend
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

    worker.deviceFound.connect(backend.deviceDiscovered)

    thread.start()


    engine.load(qml_file)
    engine.rootContext().setContextProperty("backend", backend)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())