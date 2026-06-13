import QtQuick

Rectangle {
    color: "#141414"
    anchors.fill: parent
    anchors.margins: 20
    radius: 20


    property alias model: grid.model

    GridView {
        id: grid
        height: parent.height
        anchors.fill: parent
        anchors.margins: 20
        cellWidth: 120
        cellHeight: 120

        delegate: Rectangle {
            id: tile
            width: 100
            height: 100
            radius: 20
            color: mouseArea.containsMouse ? "#444444" : "#141414"
            border.color: Qt.lighter(color)

            Behavior on opacity {
                NumberAnimation {duration: 100}
            }

            HoverHandler {
                onHoveredChanged: tile.opacity = hovered ? 0.5 : 1
            }

            Column {
                spacing: 6
                anchors.fill: parent

                anchors.margins: 5

                Image {
                    id: icon
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/Computer4x.png"
                    width: 45; height: 45
                }

                Text {
                    width: parent.width
                    anchors.topMargin: 4

                    text: name
                    font.pixelSize: 11
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onClicked: {
                    if (backend)
                        backend.conRequest(ip)
                }
            }


        }
    }
}
