import QtQuick
import QtQuick.Controls
Rectangle {
    color: "#161616"
    anchors.fill: parent
    radius: 20
    border.color: "#2A2A2A"
    border.width: 1


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
            color: mouseArea.containsMouse ? "#444444" : "#141414"
            border.color: Qt.lighter(color)

            Behavior on opacity {
                NumberAnimation {duration: 80}
            }



            HoverHandler {
                onHoveredChanged: function() {
                    tile.border.color = hovered ? "#66666666" : "transparent";
                    deviceName.height = hovered ? 40 : 35;
                }
            }

            Column {
                spacing: 6
                width: parent.width - 20
                anchors.centerIn: parent



                Image {
                    id: icon
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/computer-rounded_material-symbols.png"
                    width: 45; height: 45
                }

                Text {
                    id: deviceName
                    width: parent.width
                    height: 35
                    text: name
                    font.pixelSize: 11
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    Behavior on height {
                        NumberAnimation {duration: 80}
                    }
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
