import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

import com.sample 1.0

import QtGraphicalEffects 1.0 as QGE
import QtMultimedia 5.0 as QM

ApplicationWindow {
    id :root

    signal touched(int x, int y)
    signal swipeLeft
    signal swipeRight
    signal swipeUp
    signal swipeDown

    title: qsTr("Hello World")
    width: 960
    height: 540
    visible: true

    Timer {
        interval: 1000
        triggeredOnStart: true
        repeat: true; running: true

        onTriggered: {
            _itemApi.reload();
        }
    }

    property var jsonData

    Timer {
        id: _timerFoursquare
        triggeredOnStart: true
        interval: 5000

        onTriggered: {
            if (!jsonData) return;
            _itemFoursquare.findLocalVenues(jsonData['GPS_Latitude'], jsonData['GPS_Longitude'])
        }
    }

    Item {
        id: _itemApi

        property string url: "http://172.31.99.3/vehicle"

        function reload() {
            var xmlhttp = new XMLHttpRequest();
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                    var myArr = JSON.parse(xmlhttp.responseText);
                    root.jsonData = myArr
                    //                    console.log(JSON.stringify(myArr, null, 2));
                    _textSpeed.text = myArr['Vehicle_Speed'];
                    if(!_timerFoursquare.running)
                        _timerFoursquare.restart()

                }
            }

            xmlhttp.open("GET", url, true);
            xmlhttp.send();
        }
    }

    Item {
        id: _itemFoursquare

        property string clientId: "0ZP44D0TUFT4MCJQ1XAEGTBUVKLXNDPNKFRH10LBLOYQSUTK"
        property string clientSecret: "CESYHGKFADKIS14LTRRA2G5IM3NTW0BMVL15UMOVBFP52IC3"

        property string url: "https://api.foursquare.com/v2/venues/search?ll=%lat%,%long%&oauth_token=T4F25ZCR2GRTVMI1SIDWMBYQHGUMCWHEZWHDMZFKPYE2OF3R&v=20150613"


        function findLocalVenues(latitude, longitude) {
            var xmlhttp = new XMLHttpRequest();
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                    var myArr = JSON.parse(xmlhttp.responseText);
                    console.log(JSON.stringify(myArr, null, 2));
                    _listView.model = myArr.response.venues
                }
            }

            xmlhttp.open("GET", url.replace("%lat%", latitude).replace("%long%", longitude), true);
            xmlhttp.send();
        }

    }

    Text {
        id: _textSpeed
        anchors.centerIn: parent
        font.bold: true

        color: "#00FEAA"

        font.pixelSize: 100
    }


    QM.MediaPlayer {
        id: _mediaPlayer
        source: "file:///Users/niraj/Work/hackwiththebest/qt/InputSample/simulation-2.mp4"
        autoPlay: true
    }

    QM.VideoOutput {
        id: _videoOutput
        source: _mediaPlayer
        anchors.fill: parent
    }

    SerialPort {
        //name: "/dev/cu.usbserial-FTGQCF2N"
        //baudRate: 115200

        onMessageReceived: {
            console.log("message="+message);

            var split = message.split(" ");

            var command = split[0].trim();
            if (command === "touchAt") {
                var x = split[1].split(":")[1];
                var y = split[2].split(":")[1];

                touched(x, y);
            } else if (command === "swipeUp") {
                swipeUp();
            } else if (command === "swipeRight") {
                swipeRight();
            } else if (command === "swipeLeft") {
                swipeLeft();
            } else if (command === "swipeDown") {
                swipeDown();
            }
        }
    }

    ListView {
        id: _listView

        orientation: ListView.Horizontal

        anchors.fill: parent

        Connections {
            target: root
            onSwipeRight: {
                _listView.decrementCurrentIndex();
            }
            onSwipeLeft: {
                _listView.incrementCurrentIndex();
            }
        }

        delegate: Item {
            width: 200
            height: 200

            Rectangle {
                anchors.centerIn: parent
                width: 180
                height: 180

                color: "yellow"
                Text {
                    anchors.fill: parent
                    font.pixelSize: 22
                    text: modelData.name
                    wrapMode: Text.WordWrap
                }

                Image {
                    property var icon: modelData.categories.length > 0 ? modelData.categories[0].icon : null
                    anchors.centerIn: parent
                    source: icon.prefix + "64" + icon.suffix + "?ref=" + _itemFoursquare.clientId

                    layer.enabled: true
                    layer.effect: QGE.ColorOverlay {

                        color: "black"
                    }
                }
                //                Text {
                //                    text: modelData.categories.length > 0 ? modelData.categories[0].icon.prefix : "Nothing here"
                //                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log(JSON.stringify(modelData, null, 2))
                    }
                }
            }
        }
    }
}
