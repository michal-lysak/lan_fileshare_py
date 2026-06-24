import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs

import "../Components"
Window {
    width: 640; minimumWidth: 640; maximumWidth: 640
    height: 480; minimumHeight: 480; maximumHeight: 480
    visible: true
    title: qsTr("Nearby File Sender")
    color: "#141414"

    property string senderIp: ""
    property string senderName: ""
    property string message: ""


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
            backend.addSelectedFiles(paths)
        }
    }


    Connections {
        target: backend

        function onDeviceDiscovered(name, ip) {
            console.log("QML received:", name, ip)

            deviceModel.append({
                "name": name,
                "ip": ip,
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

        function onPacketReceived(ip, packetType, device_name) {
            senderIp = ip
            senderName = device_name

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
    }

    Loader {
        id: overlay
        anchors.fill: parent
        z: 4

        onLoaded: {
            item.senderIp = senderIp
            item.senderName = senderName

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
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Discovered devices"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 25
            font.bold: true
        }

        Rectangle {
            color: "#141414"
            width: 450
            height: 250
            radius: 20

            DevicesGrid {
                model: deviceModel
            }
        }
    }
}

