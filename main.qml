import QtQuick
import QtQuick.Controls
import "qrc:/ui/Icons/qml"

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Nearby File Sender")
    color: "#141414"

    property string senderIp: ""
    property string message: ""

    signal sendPacket(string message, string ip)


    Connections {
        target: backend

        function onDeviceDiscovered(name, ip) {
            console.log("QML received:", name, ip)

            deviceModel.append({
                "name": name,
                "ip": ip
            })
        }

        function onConnectionStateChanged() {
            conState = backend.connectionState


            if (conState === "connected") {
                loader.source = "FileShare.qml"
            }
        }

        function onPacketReceived(ip, packetType) {
            senderIp = ip
            if (packetType === "CONNECTION_REQUEST")  {
                overlay.active = true
                overlay.source = "ui/ConnectionRequest.qml"
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
        active: false

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

        Rectangle {
            color: "#141414"
            width: 500
            height: 350
            radius: 20

            Rectangle {
                color: "#202020"
                anchors.fill: parent
                anchors.margins: 20
                radius: 20

                GridView {
                    anchors.fill: parent
                    anchors.margins: 20
                    cellWidth: 120
                    cellHeight: 120
                    model: deviceModel

                    delegate: Rectangle {
                        width: 100
                        height: 100
                        radius: 20
                        color: "#333333"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Clicked:", name, ip)
                                backend.conRequest(ip)
                            }
                        }

                        Column {
                            spacing: 6
                            anchors.centerIn: parent

                            ComputerIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: name
                                color: "white"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
