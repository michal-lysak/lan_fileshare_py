import QtQuick 2.15

Rectangle {
    id: reqOverlay
    anchors.fill: parent
    color: "black"
    opacity: 0.75

    property string senderIp: ""
    property string senderName: ""
    signal requestDiscard()
    signal requestAccept()
    signal doConnection()

    Rectangle {
        anchors.centerIn: parent
        height: 130
        width: 300
        color: "#141414"
        radius: 15

        Text {
            text: senderName + " wants to share files with you"
            color: "white"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: 20
            anchors.bottomMargin: 15

            ActionButton {
                textObject.text: "Accept"
                onClicked: {
                    reqOverlay.requestAccept()
                }
            }

            ActionButton {
                textObject.text: "Decline"
                onClicked: {
                    reqOverlay.requestDiscard()
            }
            }
        }
    }
}
