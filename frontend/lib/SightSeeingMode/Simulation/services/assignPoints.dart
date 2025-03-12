import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/SsmPlay.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';

//function to iterate through the sightmode and get the source,waypoints and destination
void assignPoints(
  Map<String, dynamic> sightMode,
  Function(LatLng, LatLng, List<LatLng>, bool) upatStateCallback,
  BuildContext context,
) {
  if (sightMode.isEmpty || !sightMode.containsKey('sights')) {
    print('No sights available');
    return;
  }

  // Extract the list of sights
  List<dynamic> sights = sightMode['sights'];

  if (sights.isEmpty) {
    print('No sights available');
    return;
  }

  // Sort the sights by the 'id' key (timestamp in milliseconds since epoch)
  sights.sort((a, b) => a['id'].compareTo(b['id']));

  // Get the first sight as source
  var source = sights.first;

  // Get the last sight as destination
  var destin = sights.last;

  // Get the waypoints (all intermediate sights between first and last)
  var waypoints_list = sights.sublist(0, sights.length - 1);

  //set the state variables
  upatStateCallback(
    LatLng(source['lat'], source['long']),
    LatLng(destin['lat'], destin['long']),
    waypoints_list.map((wp) => LatLng(wp['lat'], wp['long'])).toList(),
    true,
  );

  //Alerts
  var alertMessage2 =
      "source ${SsmPlayState.sourceLocation}, destination ${SsmPlayState.destination}, waypoints ${SsmPlayState.waypoints}, isDataLoaded ${SsmPlayState.isDataLoaded}";

  showAlertDialog2(context,"recieved $alertMessage2");

  //Output source, destination, and waypoints
  print('Source:');
  print('Name: ${source['description']}');
  print('Latitude: ${source['lat']}, Longitude: ${source['long']}');

  print('\nDestination:');
  print('Name: ${destin['description']}');
  print('Latitude: ${destin['lat']}, Longitude: ${destin['long']}');

  if (waypoints_list.isNotEmpty) {
    print('\nWaypoints:');
    for (var waypoint in waypoints_list) {
      print('Name: ${waypoint['description']}');
      print('Latitude: ${waypoint['lat']}, Longitude: ${waypoint['long']}');
    }
  } else {
    print('\nNo waypoints available.');
  }

  // Build the alert message
  String alertMessage = 'Source:\n'
      'Name: ${source['description']}\n'
      'Latitude: ${source['lat']}, Longitude: ${source['long']}\n\n'
      'Destination:\n'
      'Name: ${destin['description']}\n'
      'Latitude: ${destin['lat']}, Longitude: ${destin['long']}\n\n';

  if (SsmPlayState.waypoints.isNotEmpty) {
    alertMessage += 'Waypoints:\n';
    for (var waypoint in waypoints_list) {
      alertMessage +=
          'Name: ${waypoint['description']}\nLatitude: ${waypoint['lat']}, Longitude: ${waypoint['long']}\n';
    }
  } else {
    alertMessage += 'No waypoints available.';
  }
  // Show the alert dialog
  showAlertDialog2(context,alertMessage);
}
