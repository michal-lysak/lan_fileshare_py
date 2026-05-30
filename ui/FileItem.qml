import QtQuick 2.15

Rectangle {
    property string filePath: ""
    property string fileName: filePath.split("/").pop()

    width: 100
    height: 100
    color: "transparent"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Image {
            source: "./Icons/file-icon.png"
            height: 30; width: 30
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