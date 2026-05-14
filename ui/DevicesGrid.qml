import QtQuick
import "qrc:/ui/Icons/qml"

Rectangle {
    color: "#202020"
    anchors.fill: parent
    anchors.margins: 20
    radius: 20


    property alias model: grid.model

    GridView {
        id: grid

        anchors.fill: parent
        anchors.margins: 20
        cellWidth: 120
        cellHeight: 120

        delegate: Rectangle {
            id: tile
            width: 100
            height: 100
            radius: 20
            color: mouseArea.containsMouse ? "#444444" : "#333333"

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onClicked: {
                    if (backend)
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
