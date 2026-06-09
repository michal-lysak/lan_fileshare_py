import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import "../Components"
Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Nearby File Sender")
    color: "#141414"

    property string senderIp: ""
    property string message: ""

    property var filePaths: backend.selectedFiles

    signal sendPacket(string message, string ip)

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            console.log("Selected files:", selectedFiles)

            // Convert the QUrl array to a clean string array before sending to Python
            var paths = []
            for (var i = 0; i < selectedFiles.length; i++) {
                paths.push(selectedFiles[i].toString())
            }

            //second option: var paths = selectedFiles.map(f => f.toString())

            backend.addSelectedFiles(paths)
        }
    }


    Connections {
        target: backend

        function onDeviceDiscovered(name, ip) {
            console.log("QML received:", name, ip)

            deviceModel.append({
                "name": name,
                "ip": ip
            })
        }

        function onConnectionStateUpdated(state) {
            console.log(state)

             if (state === "connected") {
                loader.source = "FileShare.qml"
            }
        }

        function onActivityStateUpdated(state) {
            console.log(state)

            if (state === "choosing") {
                fileDialog.open()
                backend.setActivityState("idle")
            }


        }

        function onPacketReceived(ip, packetType) {
            senderIp = ip
            if (packetType === "CONNECTION_REQUEST")  {
                overlay.source = "../Components/ConnectionRequest.qml"
            }
            if (packetType === "CONNECTION_ACCEPTED") {
                backend.tcpConnectOnServer(senderIp)
            }
            if (packetType === "CONNECTION_REJECTED") {

            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        z: 3

        onLoaded: {
            loader.item.senderRequest = senderIp
        }
    }

    Loader {
        id: overlay
        anchors.fill: parent
        z: 4

        onLoaded: {
            item.senderRequest = senderIp

            item.requestDiscard.connect(function() {
                overlay.source = ""
                message = "CONNECTION_REJECTED"
                backend.sendPacket(senderIp, message)
            })

            item.requestAccept.connect(function() {
                overlay.source = ""
                message = "CONNECTION_ACCEPTED"
                backend.tcpStartServer()

                backend.sendPacket(senderIp, message)
            })

            item.doConnection.connect(function() {

            })
        }
    }


    ListModel {
        id: deviceModel
    }

    Column {
        spacing: 20
        anchors.centerIn: parent

       // Rectangle {height: 40}

        Text {
            text: "Discovered devices"
            font.family: "Segoe UI"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 20
            font.bold: true
        }

        Rectangle {
            color: "#141414"
            width: 500
            height: 350
            radius: 20

            DevicesGrid {
                model: deviceModel
            }
        }
    }
}

