import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtWebKit 3.0
import QtGraphicalEffects 1.0 as QGE

ApplicationWindow {
    id: root

    property bool production: true

    width: 960
    height: 540
    visible: true

    visibility: production ? "FullScreen" : "Windowed"
    flags: Qt.FramelessWindowHint


    Api {
        id: _api
    }

    Simulator {
        id: _simulator

        onPlayVideo: {
            _dashcam.player.play()
        }

        onPauseVideo: {
            _dashcam.player.pause()
        }
    }

    Image {
        anchors.fill: parent

        source: "img/bg.jpg"
    }

    Item {
        id: _itemMenu
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: _itemContainer.left
        width: 400

        ListView {
            anchors.fill: parent
            model: [
                {
                    "text": "Radio",
                    "selected" : false
                },
                {
                    "text": "Media",
                    "selected" : false
                },
                {
                    "text": "Navigation",
                    "selected" : true
                },
                {
                    "text": "Settings",
                    "selected" : false
                }
            ]

            delegate: Item {
                width: ListView.view.width
                height: 80

                Rectangle {
                    anchors.fill: parent
                    color: "#222222"
                    opacity: 0.65
                }

                Rectangle {
                    height: 1
                    width: parent.width

                    color: "#222222"
                }

                TextLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    font.italic: true
                    font.bold: Font.DemiBold
                    text: modelData.text

                    opacity: modelData.selected ? 1.0 : 0.6
                }
            }
        }
    }

    Item {
        id: _itemContainer
        anchors.fill: parent
        focus: true

        Keys.onRightPressed: {

            if (state === "menuOpen") {
                state = ""
            } else {
                state = "menuOpen"
            }
        }

        Keys.onLeftPressed: {
            _venues.listOpen ^= 1
        }

        states: [
            State {
                name: "menuOpen"
                PropertyChanges {
                    target: _itemContainer
                    anchors.leftMargin: 400
                }
            }
        ]

        transitions: [
            Transition {
                SequentialAnimation {
                    NumberAnimation {
                        target: _itemContainer
                        property: "anchors.leftMargin"
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        ]

        Dashcam {
            id: _dashcam

            layer.enabled: true
            layer.effect: QGE.FastBlur {
                radius: 100

                Behavior on radius {
                    SequentialAnimation {
                        PauseAnimation { duration: 1000 }
                        NumberAnimation { duration: 2000 }
                    }
                }

                Component.onCompleted: {
                    radius = 0
                }
            }

            MouseArea {
                anchors.fill: parent
                drag.target: parent
                onClicked: {
                    if (_simulator.running) {
                        _simulator.pause()
                    } else {
                        _simulator.play();
                    }
                }
            }

            Venues {
                id: _venues

                anchors.fill: parent
            }
        }
    }
}
