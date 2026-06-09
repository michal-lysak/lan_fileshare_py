import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {


    property var selectedIndexes : []


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
                model: backend.selectedFiles

                Connections {
                    target: backend
                    onDeleteIndexes: {
                        console.log("")
                    }
                }

                delegate: FileItem {
                   filePath: modelData

                   selected: selectedIndexes.includes(index)

                   MouseArea {
                       anchors.fill: parent

                       onClicked: function(mouse) {
                           if (mouse.modifiers & Qt.ControlModifier) {

                               if (selectedIndexes.includes(index))
                                   selectedIndexes = selectedIndexes.filter(i => i !== index)
                               else
                                   selectedIndexes = selectedIndexes.concat(index)

                           } else {
                               selectedIndexes = [index]
                           }
                       }
                   }
                }

                Text {
                    anchors.centerIn: parent
                    text: "No files selected"
                    color: "#666666"
                    font.pixelSize: 14
                    visible: filePaths.length === 0
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
                        source: "./Icons/plus-icon.png"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                backend.activityState = "choosing"
                            }
                        }
                    }

                    FilesOverlayItem {
                        source: "./Icons/trash-icon.png"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                backend.deleteIndexes(selectedIndexes)
                                selectedIndexes.pop()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 35
            radius: 15
            color: sendArea.pressed ? "#F2EDED" : "#FFFAFA"
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Send"
                color: "black"
                anchors.centerIn: parent
                font.pixelSize: 12
            }

            MouseArea {
                id: sendArea
                anchors.fill: parent
                onClicked: {
                    backend.sendData()
                }
            }
        }
    }
}
