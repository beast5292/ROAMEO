// import 'package:practice/SightSeeingMode/Simulation/pages/Ssmplay.dart' as simulation;
// import 'flu'

// //function to get the current location (using the location package)
// void getCurrentLocation() async {
//   //hold the current location
//   Location location = Location();

//   //get the current location using getlocation and uses then to handle the result (Location package)
//   location.getLocation().then(
//     (location) {
//       setState(() {
//         //set the current location to the obtained location
//         currentLocation = location;
//       });

//       //call getPolyPoints after a obtaining the current location
//       getPolyPoints();
//     },
//   );

//   //waits for the google map controller to be available
//   GoogleMapController googleMapController = await _controller.future;

//   //listens to the stream function onLocationChanged in location package and a callback function everytime location changes
//   location.onLocationChanged.listen((newLoc) {
//     //current Location changes to newLocation
//     simulation.setState(() {
//       currentLocation = newLoc;
//     });

//     //checks the proximity everytime the location changes
//     checkProximityAndNotify();

//     //Recalculate the polyline with updated location
//     getPolyPoints();

//     //call the waypoint distance and duration calculator using current locaton anf the first active waypoint
//     getWaypointDistanceandDuration(currentLocation, activeWaypoints[0]);

//     //call the current locaton to destination distance matrix api request (full sightseeing mode duration and distance)
//     getDistanceAndDuration();

//     //dynamically update the navigation steps
//     if (navigationSteps.isEmpty || currentStepIndex >= navigationSteps.length)
//       return;

//     LatLng userLatLng = LatLng(newLoc.latitude!, newLoc.longitude!);

//     //Update current step's distance
//     double distanceToStep = calculateDistance(
//         userLatLng, navigationSteps[currentStepIndex]['distance']);

//     setState(() {
//       navigationSteps[currentStepIndex]['distance'] = distanceToStep;
//     });

//     //If user reaches the step, move to the next step
//     if (distanceToStep < 10) {
//       setState(() {
//         //Move to the next instruction
//         currentStepIndex++;
//       });
//     }

//     //change the animate Camera of the controller to the new location
//     googleMapController.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//           target: LatLng(newLoc.latitude!, newLoc.longitude!),
//           zoom: 15.5 //fixed zoom level
//           ),
//     ));

//     //call the setState which includes a set of functions
//     // setState(() {});
//   });
// }
