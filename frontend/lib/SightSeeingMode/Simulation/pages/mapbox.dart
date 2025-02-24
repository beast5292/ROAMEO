// import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

// class MapboxMapWidget extends StatefulWidget {
//   @override
//   _MapboxMapWidgetState createState() => _MapboxMapWidgetState();
// }

// class _MapboxMapWidgetState extends State<MapboxMapWidget> {
//   @override
//   void initState() {
//     super.initState();
//     _setDefaultMapOptions();
//   }

//   void _setDefaultMapOptions() {
//     MapBoxNavigation.instance.setDefaultOptions(MapBoxOptions(
//       initialLatitude: 36.1175275,
//       initialLongitude: -115.1839524,
//       zoom: 13.0,
//       tilt: 0.0,
//       bearing: 0.0,
//       enableRefresh: false,
//       alternatives: true,
//       voiceInstructionsEnabled: false,
//       bannerInstructionsEnabled: false,
//       allowsUTurnAtWayPoints: true,
//       mode: MapBoxNavigationMode.drivingWithTraffic,
//       mapStyleUrlDay: "https://url_to_day_style", // Customize styles
//       mapStyleUrlNight: "https://url_to_night_style",
//       units: VoiceUnits.imperial,
//       simulateRoute: false,
//       language: "en",
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mapbox Map Interface'),
//       ),
//       body: Center(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           child: MapboxMap(
//             styleString: "mapbox://styles/mapbox/streets-v11", // Example Mapbox style
//             initialCameraPosition: CameraPosition(
//               target: LatLng(36.1175275, -115.1839524),
//               zoom: 13.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
