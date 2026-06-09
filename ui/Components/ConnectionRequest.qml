import QtQuick 2.15

Rectangle {
    id: reqOverlay
    anchors.fill: parent
    color: "black"
    opacity: 0.75

    property string senderRequest: ""
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
            text: senderRequest + " wants to share files with you, do you agree?"
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

            Rectangle {
                radius: 15
                width: 120
                height: 35
                color: "white"

                Text {
                    text: "Yes"
                    color: "black"
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        reqOverlay.requestAccept();
                    }
                }
            }

            Rectangle {
                radius: 15
                width: 120
                height: 35
                color: "white"
                Text {
                    text: "No"
                    color: "black"
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        reqOverlay.requestDiscard()
                    }
                }
            }
        }
    }
}
