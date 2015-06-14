import QtQuick 2.0
import "utils"

Item {
    id: root

    signal playVideo
    signal pauseVideo

    property int simulatorIndex: 2
    property int currentIndex: 0
    property var currentData: _jsonListModel.model.count > 0 ? _jsonListModel.model.get(currentIndex) : null
    readonly property bool running: _timer.running

    property var lastLatLongs: []

    function play() {
        _timer.restart()
        playVideo()
    }

    function pause() {
        _timer.stop()
        pauseVideo()
    }

    function getData(key) {
        if (currentData && typeof currentData[key] !== "undefined") {
            return currentData[key];
        }
        return "";
    }

    Timer {
        id: _timer
        interval: 275
        repeat: true

        onTriggered: {
            if (currentData) {
                var ll = lastLatLongs
                ll.push({ "lat" : getData('GPS_Latitude'), "long" : getData('GPS_Longitude') })

                ll = ll.reverse()
                ll.splice(0, 50);
                ll = ll.reverse();

                lastLatLongs = ll
            }

            root.currentIndex = (root.currentIndex + 1) % _jsonListModel.count
        }
    }

    JSONListModel {
        id: _jsonListModel
        source: "http://127.0.0.1/hack/simulation-data/simulation-" + root.simulatorIndex + ".json"
        query: "$.responses[*]"
    }

    function webRequest(requestUrl, callback){
        console.log("url="+requestUrl)
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            var response;
            if(request.readyState === XMLHttpRequest.DONE) {
                if(request.status === 200) {
                    response = JSON.parse(request.responseText);
                } else {
                    console.log("Server: " + request.status + "- " + request.statusText);
                    response = ""
                }
                callback(response, request, requestUrl)
            }
        }
        request.open("GET", requestUrl, true); // only async supported
        request.send();
    }
}

