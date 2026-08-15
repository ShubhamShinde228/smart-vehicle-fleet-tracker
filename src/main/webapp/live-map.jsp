<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Live Vehicle Tracking</title>

    <!-- GOOGLE MAP (NO API KEY FOR TEST) -->
    <script src="https://maps.googleapis.com/maps/api/js"></script>

    <script>
        let map;
        let marker;

        function initMap() {

            let defaultLocation = { lat: 19.0760, lng: 72.8777 };

            map = new google.maps.Map(document.getElementById("map"), {
                zoom: 12,
                center: defaultLocation
            });

            marker = new google.maps.Marker({
                position: defaultLocation,
                map: map
            });

            loadData();

            setInterval(loadData, 5000);
        }

        function loadData() {

            fetch("get-latest-locations")
                .then(response => response.json())
                .then(data => {

                    console.log(data); // DEBUG

                    if (data.length > 0) {

                        let lat = parseFloat(data[0].latitude);
                        let lng = parseFloat(data[0].longitude);

                        let newPos = { lat: lat, lng: lng };

                        marker.setPosition(newPos);
                        map.setCenter(newPos);
                    }
                })
                .catch(error => console.log("Error:", error));
        }
    </script>

    <style>
        body {
            font-family: Arial;
            background: #f4f6f8;
        }

        #map {
            height: 500px;
            width: 80%;
            margin: auto;
            border-radius: 10px;
        }

        h2 {
            text-align: center;
        }
    </style>
</head>

<body onload="initMap()">

<h2>🚗 Live Vehicle Tracking Map</h2>

<div id="map"></div>

</body>
</html>