import QtQuick

Row {
    spacing: 5
    anchors.horizontalCenter: parent.horizontalCenter
    Image {
        source: "../../assets/icons/mingcute_computer-fill.svg"
        width: 20; height: 20
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: peerName
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        source: "../../assets/icons/mingcute_close-fill.svg"
        width: 10; height: 10
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            // TODO: create backend signal for closing connection
            onClicked: backend.closeConnection()
        }
    }
}