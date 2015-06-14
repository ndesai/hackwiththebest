import QtQuick 2.4
import QtGraphicalEffects 1.0 as QGE
Item {
    id: root

    property string location: ""

    Timer {
        id: _timerLimiter
        interval: 10000
    }

    Connections {
        target: _simulator
        onCurrentDataChanged: {

            if (_timerLimiter.running) {
                return;
            }

            _timerLimiter.restart();
            var currentData = _simulator.currentData

            if (!currentData) {
                return;
            }

            var latitude = _simulator.currentData['GPS_Latitude']
            var longitude =_simulator.currentData['GPS_Longitude']

            if (latitude && longitude) {
                _api.findLocalVenues(latitude, longitude, function(response) {
                    root.location = response.response.headerFullLocation
                    if (response.response
                            && response.response.groups
                            && response.response.groups[0]
                            && response.response.groups[0].items) {
                        _listView.model = response.response.groups[0].items.slice(0, 5)
                    }
                });
            }
        }
    }

    ListView {
        id: _listView
        anchors.fill: parent
        delegate: Item {

            property double distance: _api.howFarFromMe(modelData.venue.location.lat,
                                                        modelData.venue.location.lng)

            property double bearing:_api.whatBearingFromMe(modelData.venue.location.lat,
                                                           modelData.venue.location.lng)

            function bearingToHeading(bearing) {
                var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
                return directions[Math.round((bearing % 360) / 45)];
            }

            width: ListView.view.width
            height: 90

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.bottomMargin: 20
                radius: 2

                color: "#AA222222"

                Item {
                    id: _itemImageContainer
                    height: parent.height
                    width: _imageIcon.status !== Image.Ready ? 0 : height
                    clip: true

                    Behavior on width {
                        NumberAnimation { easing.type: Easing.OutBack; duration: 180 }
                    }

                    Image {
                        id: _imageIcon
                        property var icon: modelData.venue.categories.length > 0 ? modelData.venue.categories[0].icon : null
                        anchors.centerIn: parent
                        width: 52
                        fillMode: Image.PreserveAspectFit

                        source: icon.prefix + "64" + icon.suffix + "?ref=" + _api.clientId
                        asynchronous: true
                        cache: true
                    }
                }

                Column {
                    anchors.left: _itemImageContainer.right
                    anchors.right: _itemArrowContainer.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: _itemImageContainer.verticalCenter
                    height: childrenRect.height

                    TextLabel {
                        width: parent.width - 10
                        font.pixelSize: 16
                        color: "#ffffff"
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap

                        text: modelData.venue.name
                    }

                    TextLabel {
                        width: parent.width - 10
                        font.pixelSize: 12
                        color: "#dddddd"
                        elide: Text.ElideRight

                        text: String(distance).substr(0, 4) + " miles" + " " + bearingToHeading(Math.floor(bearing))
                    }
                }

                Item {
                    id: _itemArrowContainer
                    anchors.right: parent.right
                    width: parent.height
                    height: width

                    Image {
                        id: _imageArrow
                        anchors.centerIn: parent
                        width: 32
                        fillMode: Image.PreserveAspectFit
                        source: "img/arrow.png"

                        transformOrigin: Item.Center
                        rotation: bearing

                        Behavior on rotation {
                            NumberAnimation { duration: 200 }
                        }

                        layer.smooth: true
                        layer.enabled: true
                        layer.effect: QGE.ColorOverlay {
                            color: "#dddddd"
                        }
                    }
                }
            }
        }
    }
}

