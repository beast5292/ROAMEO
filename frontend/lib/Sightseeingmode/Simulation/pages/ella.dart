// void getPolyPoints() async {
//   // Clear existing polylines
//   polylineCoordinates.clear();

//   // Define waypoints excluding reached ones
//   activeWaypoints = waypoints
//       .where((wp) => !reachedWaypoints.contains(wp))
//       .map((wp) => "${wp.latitude},${wp.longitude}")
//       .toList();

//   // Prepare the Directions API URL
//   String origin = "${currentLocation!.latitude},${currentLocation!.longitude}";
//   String destination = "${destination!.latitude},${destination!.longitude}";
//   String waypointsString = activeWaypoints.join('|');

//   String url =
//       'https://maps.googleapis.com/maps/api/directions/json?'
//       'origin=$origin&'
//       'destination=$destination&'
//       'waypoints=optimize:true|$waypointsString&'
//       'mode=transit&' // Use transit mode
//       'transit_mode=rail&' // Specify train route
//       'key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0'; // Replace with your API key

//   // Make the HTTP request to the Directions API
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);

//     if (data['routes'].isNotEmpty) {
//       // Extract the polyline points for the train route
//       String polyline = data['routes'][0]['overview_polyline']['points'];
//       List<LatLng> trainRoute = decodePolyline(polyline);

//       setState(() {
//         polylineCoordinates = trainRoute;
//       });

//       // Print train route details
//       printTrainRouteDetails(data);
//     } else {
//       print('No train route found.');
//       // Fall back to driving mode if no train route is available
//       getDrivingRoute();
//     }
//   } else {
//     print('Failed to load directions.');
//   }
// }

// void printTrainRouteDetails(Map<String, dynamic> data) {
//   List<dynamic> routes = data['routes'];
//   for (var route in routes) {
//     List<dynamic> legs = route['legs'];
//     for (var leg in legs) {
//       List<dynamic> steps = leg['steps'];
//       for (var step in steps) {
//         if (step['travel_mode'] == 'TRANSIT' && step['transit_details'] != null) {
//           var transitDetails = step['transit_details'];
//           var vehicleType = transitDetails['line']['vehicle']['type'];

//           if (vehicleType == 'TRAIN') {
//             print('Train route found!');
//             print('Train Line: ${transitDetails['line']['name']}');
//             print('Departure Stop: ${transitDetails['departure_stop']['name']}');
//             print('Arrival Stop: ${transitDetails['arrival_stop']['name']}');
//           }
//         }
//       }
//     }
//   }
// }

// void getDrivingRoute() async {
//   // Prepare the Directions API URL for driving mode
//   String origin = "${currentLocation!.latitude},${currentLocation!.longitude}";
//   String destination = "${destination!.latitude},${destination!.longitude}";
//   String waypointsString = activeWaypoints.join('|');

//   String url =
//       'https://maps.googleapis.com/maps/api/directions/json?'
//       'origin=$origin&'
//       'destination=$destination&'
//       'waypoints=optimize:true|$waypointsString&'
//       'mode=driving&' // Fallback to driving mode
//       'key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0'; // Replace with your API key

//   // Make the HTTP request to the Directions API
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);

//     if (data['routes'].isNotEmpty) {
//       // Extract the polyline points for the driving route
//       String polyline = data['routes'][0]['overview_polyline']['points'];
//       List<LatLng> drivingRoute = decodePolyline(polyline);

//       setState(() {
//         polylineCoordinates = drivingRoute;
//       });
//     } else {
//       print('No driving route found.');
//     }
//   } else {
//     print('Failed to load driving directions.');
//   }
// }

// List<LatLng> decodePolyline(String encoded) {
//   List<LatLng> points = [];
//   int index = 0, len = encoded.length;
//   int lat = 0, lng = 0;

//   while (index < len) {
//     int b, shift = 0, result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lat += dlat;

//     shift = 0;
//     result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lng += dlng;

//     points.add(LatLng(lat / 1e5, lng / 1e5));
//   }

//   return points;
// }