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


            if (conState === "connecting") {
                loader.source = "FileShare.qml"
            }
        }

        function onPacketReceived(ip, packetType) {
            senderIp = ip
            if (packetType === "CONNECT_REQUEST")  {
                overlay.active = true
                overlay.source = "ui/ConnectionRequest.qml"
            }
            if (packetType === "CONNECT_ACCEPTED") {

            }
            if (packetType === "CONNECT_REJECTED") {

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
            })

            item.requestAccept.connect(function() {
                overlay.source = ""
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
