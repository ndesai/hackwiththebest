import QtQuick 2.0

Item {
    id: root

    property string clientId: "0ZP44D0TUFT4MCJQ1XAEGTBUVKLXNDPNKFRH10LBLOYQSUTK"
    property string clientSecret: "CESYHGKFADKIS14LTRRA2G5IM3NTW0BMVL15UMOVBFP52IC3"

    property string url: "https://api.foursquare.com/v2/venues/explore?client_id=" + clientId
                         + "&client_secret=" + clientSecret
                         + "&ll=%lat%,%long%&v=20150613"


    function findLocalVenues(latitude, longitude, callback) {
        webRequest(url.replace("%lat%", latitude).replace("%long%", longitude), callback);
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


    function howFarFromMe(latitude, longitude) {
        var latlong = [_simulator.currentData['GPS_Latitude'], _simulator.currentData['GPS_Longitude']]
        return haversineDistance(latlong, [latitude, longitude], true)
    }

    function whatBearingFromMe(latitude, longitude) {
        return getBearing(_simulator.currentData['GPS_Latitude'],  _simulator.currentData['GPS_Longitude'], latitude, longitude)
    }

    function haversineDistance(coords1, coords2, isMiles) {
      function toRad(x) {
        return x * Math.PI / 180;
      }

      var lon1 = coords1[0];
      var lat1 = coords1[1];

      var lon2 = coords2[0];
      var lat2 = coords2[1];

      var R = 6371; // km

      var x1 = lat2 - lat1;
      var dLat = toRad(x1);
      var x2 = lon2 - lon1;
      var dLon = toRad(x2)
      var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      var d = R * c;

      if(isMiles) d /= 1.60934;

      return d;
    }

    function radians(n) {
      return n * (Math.PI / 180);
    }
    function degrees(n) {
      return n * (180 / Math.PI);
    }

    function getBearing(startLat,startLong,endLat,endLong){
      startLat = radians(startLat);
      startLong = radians(startLong);
      endLat = radians(endLat);
      endLong = radians(endLong);

      var dLong = endLong - startLong;

      var dPhi = Math.log(Math.tan(endLat/2.0+Math.PI/4.0)/Math.tan(startLat/2.0+Math.PI/4.0));
      if (Math.abs(dLong) > Math.PI){
        if (dLong > 0.0)
           dLong = -(2.0 * Math.PI - dLong);
        else
           dLong = (2.0 * Math.PI + dLong);
      }

      return (degrees(Math.atan2(dLong, dPhi)) + 360.0) % 360.0;
    }
}

