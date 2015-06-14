import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: root

    property alias player: _mediaPlayer
    property double scalar: 1.5

    width: scalar*640
    height: scalar*360

    Rectangle {
        anchors.fill: parent
        color: "#222222"
        opacity: 0.65
        radius: 4
    }

    VideoOutput {
        anchors.fill: parent
        source: MediaPlayer {
            id: _mediaPlayer
            //            source: "file:///Users/niraj/Work/hackwiththebest/qt/InputSample/simulation-2-resized.mp4"
            source: "file:///Users/niraj/Work/hackwiththebest/input/simulation-" + _simulator.simulatorIndex + ".mp4"
            autoPlay: false
        }
    }
}


