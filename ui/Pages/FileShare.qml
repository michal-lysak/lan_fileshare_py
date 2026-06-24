import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Components"

Rectangle {
    property var selectedFiles_Ids : []


    anchors.fill: parent
    color: "#141414"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Rectangle {
            width: 450
            height: 250
            color: "#202020"
            radius: 35
            clip: true
            anchors.horizontalCenter: parent.horizontalCenter

            GridView {
                id: listView
                anchors.fill: parent
                anchors.margins: 20
                model: fileModel

                Connections {
                    target: backend
                }

                delegate: FileItem {
                   fileName: model.fileName
                   fileId: model.id

                   selected: selectedFiles_Ids.includes(fileId)

                   MouseArea {
                       anchors.fill: parent

                       onClicked: function(mouse) {
                           if(model.direction === "incoming") return
                           if (mouse.modifiers & Qt.ControlModifier) {

                               if (selectedFiles_Ids.includes(fileId))
                                   selectedFiles_Ids = selectedFiles_Ids.filter(i => i !== fileId)
                               else
                                   selectedFiles_Ids = selectedFiles_Ids.concat(fileId)

                           } else {
                               selectedFiles_Ids = [fileId]
                           }
                       }

                       HoverHandler {
                            onHoveredChanged: function(mouse) {
                                if (hovered) {
                                    if (model.direction === "incoming") return
                                     border.color = "#66666666"
                                } else { border.color = "transparent"}
                            }

                       }

                   }
                }

                Text {
                    anchors.centerIn: parent
                    text: "No files selected"
                    color: "#666666"
                    font.pixelSize: 14
                    visible: listView.count === 0
                }

                ScrollBar.vertical: ScrollBar {
                    active: listView.moving || listView.flicking
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 6
                        implicitHeight: 100
                        radius: width / 2
                        color: "#555555"
                    }
                }
            }
            FilesOverlayBar {
                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    FilesOverlayItem {
                        id: importButton
                        source: "../../assets/icons/plus-icon.png"

                        // 1. Ensure it shrinks towards the center
                        transformOrigin: Item.Center
                        // 2. Shrink when pressed, return to normal when released
                        scale: importArea.pressed ? 0.7 : 1.0

                        Behavior on scale {
                            SpringAnimation {
                                spring: 4.0
                                damping: 0.3
                            }
                        }

                        MouseArea {
                            id: importArea
                            anchors.fill: parent
                            onClicked: {
                                backend.activityState = "choosing"
                            }
                        }
                    }

                    FilesOverlayItem {
                        id: trashButton
                        source: "../../assets/icons/trash-icon.png"

                        transformOrigin: Item.Center
                        scale: trashArea.pressed ? 0.7 : 1.0

                        Behavior on scale {
                            SpringAnimation {
                                spring: 4.0
                                damping: 0.3
                            }
                        }

                        MouseArea {
                            id: trashArea
                            anchors.fill: parent
                            onClicked: {
                                backend.deleteFiles_Ids(selectedFiles_Ids)
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            id: sendButton
            width: 120
            height: 35
            radius: 15
            color: sendArea.pressed ? "#F2EDED" : "#FFFAFA"
            anchors.horizontalCenter: parent.horizontalCenter

            // Custom property to track the click animation state
            property bool isClicked: false

            Image {
                id: arrow
                source: "../../assets/icons/arrow-up_material-line.png"
                width: 20
                height: 20

                anchors.verticalCenter: parent.verticalCenter
                x: sendText.x - 25   // sits left of text

                // 1. If clicked, fly up out of bounds (-25)
                // 2. If hovered, sit dead center (0)
                // 3. Otherwise, rest lower (10) ready to animate in
                anchors.verticalCenterOffset: sendButton.isClicked ? -25 : (sendArea.containsMouse ? 0 : 10)

                // Fade out while flying to the top
                opacity: sendButton.isClicked ? 0 : (sendArea.containsMouse ? 1 : 0)

                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
                }

                // Animate the offset instead of 'y' to respect the verticalCenter anchor
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }
            }

            Text {
                id: sendText
                text: "Send"
                font.bold: true
                color: "black"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter

                // Stay shifted right while the fly-out animation happens
                x: (sendArea.containsMouse || sendButton.isClicked) ? 55 : (parent.width - width) / 2

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: sendArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    // Prevent spam-clicking while animating
                    if (!sendButton.isClicked) {
                        sendButton.isClicked = true
                        backend.sendData()
                        resetTimer.start()
                    }
                }
            }

            Timer {
                id: resetTimer
                interval: 300
                onTriggered: sendButton.isClicked = false
            }
        }
    }
}
