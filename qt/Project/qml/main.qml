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

    Image {
        anchors.fill: parent

        source: "img/bg.jpg"
    }

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

    Dashcam {
        id: _dashcam

//        anchors.centerIn: parent

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
