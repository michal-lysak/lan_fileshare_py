import QtQuick
import QtQuick.Controls

Rectangle {
    id: fileRec
    property string fileName
    property int fileId


    property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp"]
    property string fileType : filePath.split(".").pop()

    property bool selected: false
    property bool hovered: false


    width: 100
    height: 100
    radius: 20
    color: selected ? "#3b82f6" : "transparent"

     Behavior on color {
         ColorAnimation {duration: 125}
     }

     Behavior on border.color {
         ColorAnimation {duration: 75}
     }

     HoverHandler {
         onHoveredChanged: fileRec.hovered = hovered
     }


    Column {
        anchors.centerIn: parent
        spacing: 10
        Loader {
            sourceComponent: direction === "incoming"
                                ? incomingComponent
                                : outgoingComponent
        }

        Component {
            id: incomingComponent
            Column  {
                opacity: 0.65
                spacing: 10
                Image {
                    source: imageTypes.includes(fileType)
                            ? filePath
                            : "../../assets/icons/file-icon.png"
                    height: 40; width: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ProgressBar {
                    id: inProgress
                    height: 5
                    width: parent.width
                    value: bytesReceived
                    from: 0
                    to: fileSize
                    visible: bytesReceived > 0

                }

                Text {
                    width: 80
                    text: fileName
                    color: "white"
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }

// not changable
        Component {
            id: outgoingComponent
            Column  {
                spacing: 10

                Image {
                    source: imageTypes.includes(fileType)
                            ? filePath
                            : "../../assets/icons/material-symbols-docs.png"
                    height: 40; width: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ProgressBar {
                    id: outProgress
                    height: 5
                    width: parent.width
                    value: bytesSended
                    from: 0
                    to: fileSize
                    visible: bytesSended > 0
                }

                Text {
                    width: 80
                    text: fileName
                    color: "white"
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
