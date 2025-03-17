import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/SsmPlay.dart';
import 'package:practice/SightSeeingMode/Simulation/providers/SightProvider.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';
import 'package:provider/provider.dart';

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

  //Extract the list of sights
  List<dynamic> sights = sightMode['sights'];

  if (sights.isEmpty) {
    print('No sights available');
    return;
  }

  //Save the sights in the provider
  final sightProvider = Provider.of<SightProvider>(context, listen: false);
  sightProvider.setSights(sights);

  //Get the first sight as source
  var source = sights.first;

  //Get the last sight as destination
  var destin = sights.last;

  //Get the waypoints (all intermediate sights including first and last)
  var waypointsList = sights.sublist(0, sights.length - 1);

  //set the state variables
  upatStateCallback(
    LatLng(source['lat'], source['long']),
    LatLng(destin['lat'], destin['long']),
    waypointsList.map((wp) => LatLng(wp['lat'], wp['long'])).toList(),
    true,
  );

  //Alerts
  var alertMessage2 =
      "source ${SsmPlayState.sourceLocation}, destination ${SsmPlayState.destination}, waypoints ${SsmPlayState.waypoints}, isDataLoaded ${SsmPlayState.isDataLoaded}";

  showAlertDialog2(context, "recieved $alertMessage2");

  //Output source, destination, and waypoints
  print('Source:');
  print('Name: ${source['description']}');
  print('Latitude: ${source['lat']}, Longitude: ${source['long']}');

  print('\nDestination:');
  print('Name: ${destin['description']}');
  print('Latitude: ${destin['lat']}, Longitude: ${destin['long']}');

  if (waypointsList.isNotEmpty) {
    print('\nWaypoints:');
    for (var waypoint in waypointsList) {
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
    for (var waypoint in waypointsList) {
      alertMessage +=
          'Name: ${waypoint['description']}\nLatitude: ${waypoint['lat']}, Longitude: ${waypoint['long']}\n';
    }
  } else {
    alertMessage += 'No waypoints available.';
  }
  // Show the alert dialog
  showAlertDialog2(context, alertMessage);
}
