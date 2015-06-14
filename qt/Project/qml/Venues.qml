import QtQuick 2.4
import QtGraphicalEffects 1.0 as QGE
Item {
    id: root

    property string location: ""
    property bool listOpen: true

    property string filter: ""

    signal destroyByTag(string tag);

    StateGroup {
        id: _stateGroupList

        states: [
            State {
                when: root.listOpen
                PropertyChanges {
                    target: _listView
                    anchors.rightMargin: 0
                }
            },
            State {
                when: !root.listOpen
                PropertyChanges {
                    target: _listView
                    anchors.rightMargin: -1*_listView.width
                }
            }
        ]

        transitions: [
            Transition {
                SequentialAnimation {
                    NumberAnimation {
                        target: _listView
                        property: "anchors.rightMargin"
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        ]
    }

    Timer {
        id: _timerLimiter
        interval: 3000
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
                    root.location = response.response.headerLocation
                    if (response.response
                            && response.response.groups
                            && response.response.groups[0]
                            && response.response.groups[0].items) {


                        var list = response.response.groups[0].items.slice(0, 5);
                        _listView.model = list
                        var tag = String(Math.random()*100000);

                        var listOfNewIds = []

                        for (var i = 0; i < list.length; i++) {

                            var identifier = list[i].venue.id
                            listOfNewIds.push(identifier)

                            var localMap = root.poiMap

                            var p = localMap[identifier]

                            if (!p) {
                                var poi = _componentPOI.createObject(_itemTempContainer, { "modelData": list[i], "tag" : tag })
                                localMap[identifier] = poi
                            } else {
                                //                                p.tag = tag
                                //                                p.modelData = list[i];
                            }

                            root.poiMap = localMap
                        }

                        var localMap = root.poiMap
                        for (var j = 0, keys = Object.keys(root.poiMap); j < keys.length; j++) {
                            if(listOfNewIds.indexOf(keys[j]) === -1) {
                                localMap[keys[j]].destroy();
                                delete localMap[keys[j]]
                            }
                        }
                        root.poiMap = localMap
                    }
                });
            }
        }
    }

    function checkLineIntersection(line1StartX, line1StartY, line1EndX, line1EndY, line2StartX, line2StartY, line2EndX, line2EndY) {
        // if the lines intersect, the result contains the x and y of the intersection (treating the lines as infinite) and booleans for whether line segment 1 or line segment 2 contain the point
        var denominator, a, b, numerator1, numerator2, result = {
            x: null,
            y: null,
            onLine1: false,
            onLine2: false
        };
        denominator = ((line2EndY - line2StartY) * (line1EndX - line1StartX)) - ((line2EndX - line2StartX) * (line1EndY - line1StartY));
        if (denominator == 0) {
            return result;
        }
        a = line1StartY - line2StartY;
        b = line1StartX - line2StartX;
        numerator1 = ((line2EndX - line2StartX) * a) - ((line2EndY - line2StartY) * b);
        numerator2 = ((line1EndX - line1StartX) * a) - ((line1EndY - line1StartY) * b);
        a = numerator1 / denominator;
        b = numerator2 / denominator;

        // if we cast these lines infinitely in both directions, they intersect here:
        result.x = line1StartX + (a * (line1EndX - line1StartX));
        result.y = line1StartY + (a * (line1EndY - line1StartY));
        /*
            // it is worth noting that this should be the same as:
            x = line2StartX + (b * (line2EndX - line2StartX));
            y = line2StartX + (b * (line2EndY - line2StartY));
            */
        // if line1 is a segment and line2 is infinite, they intersect if:
        if (a > 0 && a < 1) {
            result.onLine1 = true;
        }
        // if line2 is a segment and line1 is infinite, they intersect if:
        if (b > 0 && b < 1) {
            result.onLine2 = true;
        }
        // if line1 and line2 are segments, they intersect if both of the above are true
        return result;
    }

    function rotate(cx, cy, x, y, angle, scalar) {
        var radians = (Math.PI / 180) * angle,
                cos = Math.cos(radians),
                sin = Math.sin(radians),
                nx = (cos * (x - cx)) - (sin * (y - cy)) + cx,
                ny = (sin * (x - cx)) + (cos * (y - cy)) + cy;
        return [nx*scalar, ny*scalar];
    }

    Item {
        id: _itemTempContainer
        anchors.fill: parent

        z: 10000
    }

    // 4a844f01f964a5203bfc1fe3 to object
    property var poiMap: ({});

    Component {
        id: _componentPOI

        Item {
            id: _item

            property string tag: ""

            //            Connections {
            //                target: root
            //                onDestroyByTag: {
            //                    if(_item.tag === tag) {
            //                        _item.destroy();
            //                    }
            //                }
            //            }

            property var modelData: ({});

            property double distance: _api.howFarFromMe(modelData.venue.location.lat,
                                                        modelData.venue.location.lng)

            property double bearing: _api.whatBearingFromMe(modelData.venue.location.lat,
                                                            modelData.venue.location.lng)

            function bearingToHeading(bearing) {
                var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
                return directions[Math.round((bearing % 360) / 45)];
            }

            width: 52
            height: 52

            property int widthDistanceFromMax: (root.width - (width + x))
            property int heightDistanceFromMax: (root.height - (height + y))

            property int oppHeight: Math.tan(bearing) * (root.width / 2)


            property int centerX: ((root.width - width) / 2)
            property int centerY: ((root.height - height) / 2)

            x: ((root.width - width) / 2)
            y: ((root.height - height) / 2)

            visible: false

            Timer {
                running: true
                interval: 1000
                onTriggered: parent.visible = true
            }

            Behavior on x {
                SmoothedAnimation { velocity: 500 }
            }

            Behavior on y {
                SmoothedAnimation { velocity: 500 }
            }

            //            onDistanceChanged: {
            //                if (distance > 0.5) {
            //                    console.log()
            //                    console.log("destroy !modelData.venue.name = " + modelData.venue.name,
            //                                "distance = " + distance)
            //                    destroy()
            //                }
            //            }

            onBearingChanged: {

                var l = root.rotate(0, 0, 0, 1, bearing, 1000);
                l[0] += centerX;
                l[1] += centerY;

                var r
                var cardinalDirection = Math.floor((bearing % 360) / 90)
                console.log("modelData.venue.name = " + modelData.venue.name,
                            "bearing = " + bearing,
                            "cardinalDirection = " + cardinalDirection)
                switch (cardinalDirection) {
                case 0:
                    // N
                    r = checkLineIntersection(centerX, centerY, l[0], l[1], 0, 0, root.width, 0)

                    break;

                case 1:
                    // E

                    r = checkLineIntersection(centerX, centerY, l[0], l[1], 0, root.width, root.width, root.height)

                    break;
                case 2:
                    // S
                    r = checkLineIntersection(centerX, centerY, l[0], l[1], 0, root.height, root.width, root.height)


                    break;
                case 3:
                    // W
                    r = checkLineIntersection(centerX, centerY, l[0], l[1], 0, 0, 0, root.height)

                    break;
                }

                x = Math.max(0, Math.min(r.x, root.width - width))
                y = Math.max(0, Math.min(r.y, root.height - height))

            }

            Item {
                anchors.fill: parent

                Item {
                    id: _itemImageContainer
                    height: 52
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

                    layer.enabled: true
                    layer.effect: QGE.DropShadow {
                        radius: 2
                        samples: 6
                        verticalOffset: 2
                        horizontalOffset: 2
                        color: "#000000"
                    }
                }
            }
        }
    }

    TextLabel {
        anchors.left: _listView.left
        anchors.right: _listView.right
        anchors.bottom: _listView.top
        anchors.bottomMargin: 10

        font.italic: true
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        elide: Text.ElideRight
        font.pixelSize: 24

        text: root.location
    }

    ListView {
        id: _listView


        width: 260
        anchors.right: parent.right
        height: delegateHeight * 5
        anchors.verticalCenter: parent.verticalCenter

        property int delegateHeight: 70

        model: root.model
        delegate: _delegate

        onCountChanged: {
            console.log("count = " + count)
        }

        Component {
            id: _delegate

            Item {

                property double distance: _api.howFarFromMe(modelData.venue.location.lat,
                                                            modelData.venue.location.lng)

                property double bearing:_api.whatBearingFromMe(modelData.venue.location.lat,
                                                               modelData.venue.location.lng)

                function bearingToHeading(bearing) {
                    var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
                    return directions[Math.round((bearing % 360) / 45)];
                }

                width: ListView.view.width
                height: ListView.view.delegateHeight

                Rectangle {
                    anchors.fill: parent
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
                            width: 40
                            fillMode: Image.PreserveAspectFit

                            source: icon.prefix + "64" + icon.suffix + "?ref=" + _api.clientId
                            asynchronous: true
                            cache: true
                        }
                    }

                    Column {
                        anchors.left: _itemImageContainer.right
                        anchors.right: parent.right
                        anchors.verticalCenter: _itemImageContainer.verticalCenter
                        height: childrenRect.height

                        TextLabel {
                            width: parent.width - 10
                            font.pixelSize: 16
                            color: "#ffffff"
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight

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
                }
            }
        }
    }
}

