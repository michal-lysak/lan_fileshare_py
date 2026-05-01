import QtQuick
import QtQuick.Controls
import "qrc:/ui/Icons/qml"

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Nearby File Sender")
    color: "#141414"

    Connections {
        target: backend

        function onDeviceDiscovered(name, ip) {
            console.log("QML received:", name, ip)

            deviceModel.append({
                "name": name,
                "ip": ip
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