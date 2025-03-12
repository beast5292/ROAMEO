//  //Use google ROADS API to snap polyline coorindates to the nearest road
//   Future<void> snapToRoads(List<LatLng> routePoints) async {
//     //get the path of all the coordinates of the path and snap it to the nearest road
//     String waypoints_snapped = routePoints
//         .map((LatLng point) => '${point.latitude},${point.longitude}')
//         .join('%7C');

//     print(waypoints_snapped);

//     print(waypoints_snapped.length);

//     String url =
//         'https://roads.googleapis.com/v1/snapToRoads?path=$waypoints_snapped&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

//     var response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       List<LatLng> snappedCoordinates = [];

//       for (var snappedPoint in data['snappedPoints']) {
//         double lat = snappedPoint['location']['latitude'];
//         double lng = snappedPoint['location']['longitude'];
//         snappedCoordinates.add(LatLng(lat, lng));
//       }

//       // var alertMessage3 = snappedCoordinates.toString();

//       // showAlertDialog2(alertMessage3);

//       //set the polyline coordinates to snapped coordinates
//       setState(() {
//         polylineCoordinates = snappedCoordinates;
//       });
//     } else {
//       print("Failed to snap to roads: ${response.statusCode}");

//       // var alertMessage3 = "Failed to snap to roads ${response.statusCode}";

//       // showAlertDialog2(alertMessage3);
//     }
//   }