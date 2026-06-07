import QtQuick

Rectangle {
    id: fileRec
    property string filePath: ""
    property string fileName: filePath.split("/").pop()
    property string fileType : filePath.split(".").pop()

    property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp"]

    property bool selected: false
    property bool hovered: false

    width: 100
    height: 100
    radius: 20
    color: selected ? "#3b82f6" : "transparent"

    Behavior on color {
        ColorAnimation {duration: 125}
    }

    HoverHandler {
        onHoveredChanged: fileRec.hovered = hovered
    }


    Column {
        anchors.centerIn: parent
        spacing: 10

        Image {
            source: imageTypes.includes(fileType)
                    ? "file:///" + filePath
                    : "./Icons/file-icon.png"
            height: 40; width: 40
            anchors.horizontalCenter: parent.horizontalCenter
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
