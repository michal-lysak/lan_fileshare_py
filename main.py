# This Python file uses the following encoding: utf-8
import os
os.environ["QT_LOGGING_RULES"] = "qml.debug=true"
import sys
import resources_rc
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend.backend import Backend
from backend.discovery import DiscoveryWorker
from backend.tcp_manager import TCPManager
from PySide6.QtCore import QThread, QObject, Signal, qInstallMessageHandler, QtMsgType

if __name__ == "__main__":
    # QML DEBUGGING
    def qt_message_handler(mode, context, message):
        if mode == QtMsgType.QtDebugMsg:
            print(f"[QML DEBUG] {message}")
        elif mode == QtMsgType.QtWarningMsg:
            print(f"[QML WARN]  {message}")
        elif mode == QtMsgType.QtCriticalMsg:
            print(f"[QML ERROR] {message}")
        elif mode == QtMsgType.QtFatalMsg:
            print(f"[QML FATAL] {message}")

    qInstallMessageHandler(qt_message_handler)


    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "ui" / "Pages" / "main.qml"

    backend = Backend()
    tcpManager = TCPManager(backend)

    worker = DiscoveryWorker()
    thread = QThread()

    worker.moveToThread(thread)
    thread.started.connect(worker.start)
    thread.started.connect(lambda: backend.setConnectionState("discovering"))

    worker.deviceFound.connect(backend.deviceDiscovered)
    worker.packetReceived_Signal.connect(backend.onPacketReceived)
    worker.stateChanged.connect(backend.setConnectionState)

    backend.tcpStartServer.connect(tcpManager.startServer)
    backend.tcpConnectOnServer.connect(tcpManager.connectToHost)
    backend.sendData.connect(tcpManager.sendData)
    backend.deleteIndexes.connect(backend.removeIndexes)

    backend.conRequest_Signal.connect(worker.conRequest)
    backend.sendPacket.connect(worker.sendPacket)

    thread.start()
    engine.rootContext().setContextProperty("backend", backend)

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
