# This Python file uses the following encoding: utf-8
import os

from backend.models.FileListModel import FileListModel
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


    fileModel = FileListModel()
    backend = Backend(fileModel)
    tcpManager = TCPManager(backend, fileModel)
    

    worker = DiscoveryWorker()
    thread = QThread()
    tcpThread = QThread()

    worker.moveToThread(thread)
    tcpManager.moveToThread(tcpThread)
    thread.started.connect(worker.start)

    thread.started.connect(lambda: backend.setConnectionState("discovering"))

    worker.deviceFound.connect(backend.deviceDiscovered)
    worker.packetReceived_Signal.connect(backend.onPacketReceived)
    worker.stateChanged.connect(backend.setConnectionState)

    backend.selectedFilesChanged.connect(backend.onSelectedFilesChanged)
    backend.tcpStartServer.connect(tcpManager.startServer)
    backend.tcpConnectOnServer.connect(tcpManager.connectToHost)
    backend.sendData.connect(tcpManager.sendData)
    backend.deleteFiles_Ids.connect(backend.removeFiles_Ids)

    backend.conRequest_Signal.connect(worker.conRequest)
    backend.sendPacket.connect(worker.sendPacket)

    thread.start()
    tcpThread.start()
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("fileModel", fileModel)
    engine.load(qml_file)

# Closing the app
    def cleanup():
        print("App shutting down...")

        worker.stop()

        thread.quit()
        tcpThread.quit()
        tcpThread.wait()
        thread.wait()

        print("Thread stopped cleanly")

    if not engine.rootObjects():
        sys.exit(-1)

    app.aboutToQuit.connect(cleanup)
    sys.exit(app.exec())
