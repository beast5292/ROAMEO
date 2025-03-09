 
import 'package:flutter/material.dart';



// //function to iterate through the sightmode and get the source,waypoints and destination
// void assignPoints(Map<String, dynamic> sightMode) {
//     if (sightMode.isEmpty || !sightMode.containsKey('sights')) {
//     print('No sights available');
//     return;
//   }

//     // Extract the list of sights
//     List<dynamic> sights = sightMode['sights'];

//     if (sights.isEmpty) {
//       print('No sights available');
//       return;
//     }

//     // Get the first sight as source
//     var source = sights.first;

//     // Get the last sight as destination
//     var destination = sights.last;

//     // Get the waypoints (all intermediate sights between first and last)
//     var waypoints = sights.length > 2 ? sights.sublist(1, sights.length - 1) : [];

//     // Output source, destination, and waypoints
//     print('Source:');
//     print('Name: ${source['description']}');
//     print('Latitude: ${source['lat']}, Longitude: ${source['long']}');

//     print('\nDestination:');
//     print('Name: ${destination['description']}');
//     print('Latitude: ${destination['lat']}, Longitude: ${destination['long']}');

//     if (waypoints.isNotEmpty) {
//       print('\nWaypoints:');
//       for (var waypoint in waypoints) {
//         print('Name: ${waypoint['description']}');
//         print('Latitude: ${waypoint['lat']}, Longitude: ${waypoint['long']}');
//       }
//     } else {
//       print('\nNo waypoints available.');
//     }

    
//   // Build the alert message
//   String alertMessage = 'Source:\n'
//       'Name: ${source['description']}\n'
//       'Latitude: ${source['lat']}, Longitude: ${source['long']}\n\n'
//       'Destination:\n'
//       'Name: ${destination['description']}\n'
//       'Latitude: ${destination['lat']}, Longitude: ${destination['long']}\n\n';

//   if (waypoints.isNotEmpty) {
//     alertMessage += 'Waypoints:\n';
//     for (var waypoint in waypoints) {
//       alertMessage +=
//           'Name: ${waypoint['description']}\nLatitude: ${waypoint['lat']}, Longitude: ${waypoint['long']}\n';
//     }
//   } else {
//     alertMessage += 'No waypoints available.';
  
//   }
//     // Show the alert dialog
//   showAlertDialog2(alertMessage);
// }

