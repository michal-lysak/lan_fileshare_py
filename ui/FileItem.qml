import QtQuick 2.15

Rectangle {
    property string filePath: ""
    property string fileName: filePath.split("/").pop()
    property string fileType : filePath.split(".").pop()

    property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp"]

    width: 100
    height: 100
    color: "transparent"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Image {
            source: imageTypes.includes(fileType)
                    ? filePath
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