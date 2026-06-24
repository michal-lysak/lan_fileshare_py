import QtQuick

Rectangle {
    id: actionBtn

    signal clicked()
    property alias textObject: actionText

    radius: 15
    width: 120
    height: 35
    color: "white"

    Behavior on opacity {
        NumberAnimation {
            duration:50
        }
    }

    HoverHandler {
        onHoveredChanged: actionBtn.opacity = hovered ? 0.8 : 1
    }

    Text {
        id: actionText
        text: "Decline"
        color: "black"
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: actionBtn.clicked()
    }
}