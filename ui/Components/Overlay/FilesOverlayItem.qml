import QtQuick 2.15

Rectangle {
    id: trashRec
    width: 25
    height: 25
    color: "transparent"
    radius: 10

    property alias source: iconImage.source

    Image {
        id: iconImage
        width: 25
        height: 25
        source: ""
    }

    HoverHandler {
        onHoveredChanged: trashRec.color = hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }

}
