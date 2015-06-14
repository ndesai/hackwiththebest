import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtWebKit 3.0

ApplicationWindow {
    id: root

    property bool production: false

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

        anchors.centerIn: parent

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

            width: 400

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: _dashcam.top
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
        }

//        WebView {
//            width: 640
//            height: 460
//            anchors.centerIn: parent
//            url: "http://app.st"
//        }

        TextLabel {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin: 10
            anchors.bottomMargin: 4

            font.italic: true
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase

            text: _venues.location
        }
    }
}
