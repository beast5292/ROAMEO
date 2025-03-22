import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Ella%20details/Ella_route.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Define the initial camera position using the first point of the route
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: routePoints.first,
    zoom: 14,
  );

  // Define the polyline
  final Set<Polyline> _polylines = {};

  // Define the map style
  String _mapStyle = '';

  @override
  void initState() {
    super.initState();

    // Initialize the polyline
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load the dark mode style JSON file
    DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/dark_mode.json')
        .then((string) {
      setState(() {
        _mapStyle = string;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A0E),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                mapController = controller;
              });
              // Apply the loaded map style
              if (_mapStyle.isNotEmpty) {
                mapController.setMapStyle(_mapStyle);
              }
            },
            polylines: _polylines,
          ),
          // Custom Back Button Positioned at the top left
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
