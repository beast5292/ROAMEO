import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';

//Check if the user is within 200 meters of the destination and show an alert dialog if true
void checkProximityAndNotify(
  BuildContext context,
  LocationData? currentLocation,
  List<LatLng> waypoints,
  Set<LatLng> reachedNearWaypoints,
  Set<LatLng> reachedWaypoints,
  LatLng? destination,
  Function() getPolyPoints,

) {
  //if the currentLocation has no location value return
  if (currentLocation == null) return;

  //List of LatLng objects containing coordinates of the waypoints (dummy)
  // List<LatLng> waypoints = [
  //   LatLng(6.928684, 79.878155),
  // ];

  //boolean value to store if the alert is shown
  bool alertShown = false;

  //for every waypoint in all the waypoints
  for (LatLng waypoint in waypoints) {
    //calculate distance to a waypoint from the current location using the haverSine calculation
    double distanceToWaypoint = calculateDistance(
      LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      waypoint,
    );

    //if the obtained distance to the waypoint from current location is less than 200
    if (distanceToWaypoint <= 200 && !reachedNearWaypoints.contains(waypoint)) {
      //show that you are near a waypoint
      showAlertDialog2(context, "You are near a waypoint!");

      //mark the waypoint as a reached near one to avoid duplication
      reachedNearWaypoints.add(waypoint);

      //alert will show up
      alertShown = true;
    }

    //if the obtained distance to the waypoint from current location is less than 50
    if (distanceToWaypoint <= 50 && !reachedWaypoints.contains(waypoint)) {
      //show that you have arrived at a waypoint
      showAlertDialog2(context, "You have arrived at a waypoint!");

      //add it to rezched waypoints to avoid duplication
      reachedWaypoints.add(waypoint);

      //redraw polylines without the arrived waypoints
      getPolyPoints();

      //alert will show up
      alertShown = true;
    }

    //exit the loop if one of the alerts return true
    if (alertShown) return;
  }

  //calculate the distance to destination using the haveersine calculation
  double distanceToDestination = calculateDistance(
    LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
    destination!,
  );

  //if the distance is less than 50 meteres display you have arrived
  if (distanceToDestination <= 50) {
    showAlertDialog2(context, "You have arrived at your destination!");
  }

  //if the distance is less than 200 display you are near the destination
  if (distanceToDestination <= 200) {
    showAlertDialog2(context, "You are near the destination!");
  }
}
