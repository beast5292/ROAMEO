import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/Services/SightGet.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Navigation.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/mapbox.dart';
import 'package:practice/SightSeeingMode/Simulation/providers/SightProvider.dart';
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';
import 'package:practice/SightSeeingMode/Simulation/services/TrimPolyline.dart';
import 'package:practice/SightSeeingMode/Simulation/services/assignPoints.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';
import 'package:practice/SightSeeingMode/Simulation/services/checkProximity.dart';
import 'package:practice/SightSeeingMode/Simulation/services/PolylineThresholdCheck.dart';
import 'package:practice/SightSeeingMode/Simulation/services/readCoordinatesfromfile.dart';

class SsmPlay extends StatefulWidget {
  final int index;
  final String docId;

  const SsmPlay({super.key, required this.index, required this.docId});

  @override
  State<SsmPlay> createState() => SsmPlayState();
}

class SsmPlayState extends State<SsmPlay> {
  // Loading state variable
  bool isLoading = true;

  // Add a flag to track if data is loaded
  static bool isDataLoaded = true;

  // Store the received sightseeing data in a Map
  Map<String, dynamic>? sightMode;

  // Store reached near waypoints to avoid duplicate alerts (when you are near a waypoint)
  Set<LatLng> reachedNearWaypoints = {};

  // Store reached waypoints to avoid duplicate alerts (when you reached a waypoint)
  Set<LatLng> reachedWaypoints = {};

  // Track the internet connection status
  final String _connectionStatus = 'Unknown';

  // Google map instance as a completer
  final Completer<GoogleMapController> _controller = Completer();

  // Temporary holders for the source location and destination
  static LatLng? sourceLocation;
  static LatLng? destination;
  static List<LatLng> waypoints = [];

  // Store the navigation steps received from the Directions waypoint API request
  List<Map<String, dynamic>> navigationSteps = [];

  // Track the current step index
  int currentStepIndex = 0;

  // List of LatLng coordinates to hold the polyline points
  static List<LatLng> polylineCoordinates = [];

  // Define only the active waypoints
  late List<PolylineWayPoint> activeWaypoints;

  // Store the current location (using the Location package)
  LocationData? currentLocation;

  // Distance and duration holders (for the distance matrix API response)
  String distance = '';
  String duration = '';

  // Distance and duration holders (for the Directions API request for waypoints)
  String waypointDistance = "";
  String waypointDuration = "";

  // Custom marker variables (BitmapDescriptor)
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  // Set to hold markers
  Set<Marker> markers = {};

  // Map style for dark theme
  String _mapStyle = '';

  // Callback to update assignPoints state
  void updateAssignPointsState(
    LatLng source,
    LatLng dest,
    List<LatLng> wps,
    bool loaded,
  ) {
    setState(() {
      sourceLocation = source;
      destination = dest;
      waypoints = wps;
      isDataLoaded = loaded;
    });
  }

  // Function to get the current location (using the Location package)
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((locationData) {
      setState(() {
        currentLocation = locationData;
      });
      getPolyPoints();
    });

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      setState(() {
        currentLocation = newLoc;
      });

      addMarkers();

      // Trim the polyline based on user movement
      trimPolyline(LatLng(newLoc.latitude!, newLoc.longitude!));

      // Check proximity and notify on location change
      checkProximityAndNotify(
        context,
        currentLocation,
        waypoints,
        reachedNearWaypoints,
        reachedWaypoints,
        destination,
        getPolyPoints,
      );

      // Check if the current location is within the polyline threshold
      LatLng currentLatLng = LatLng(newLoc.latitude!, newLoc.longitude!);
      if (!isLocationWithinPolylineThreshold(currentLatLng, polylineCoordinates, 50.0)) {
        // Redraw the polyline if the location is outside the threshold
        getPolyPoints();
      }

      // Update waypoint distance and overall route info
      getWaypointDistanceandDuration(currentLocation, activeWaypoints[0]);
      getDistanceAndDuration();

      // Dynamically update the navigation steps
      if (navigationSteps.isNotEmpty && currentStepIndex < navigationSteps.length) {
        LatLng userLatLng = LatLng(newLoc.latitude!, newLoc.longitude!);
        double distanceToStep = calculateDistance(
            userLatLng, navigationSteps[currentStepIndex]['distance']);
        setState(() {
          navigationSteps[currentStepIndex]['distance'] = distanceToStep;
        });
        // Move to next step if within 10 meters
        if (distanceToStep < 10) {
          setState(() {
            currentStepIndex++;
          });
        }
      }

      // Animate the camera to the new location
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newLoc.latitude!, newLoc.longitude!),
          zoom: 15.5,
        ),
      ));
    });
  }

  // Function to get the polyline points using the Directions API
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    polylineCoordinates.clear();

    activeWaypoints = waypoints
        .where((wp) => !reachedWaypoints.contains(wp))
        .map((wp) => PolylineWayPoint(
              location: "${wp.latitude},${wp.longitude}",
            ))
        .toList();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0',
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(destination!.latitude, destination!.longitude),
        travelMode: TravelMode.driving,
        wayPoints: activeWaypoints,
        optimizeWaypoints: true);

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      setState(() {
        polylineCoordinates = routePoints;
      });
    }
  }

  // Distance matrix API request for the full sightseeing route
  Future<void> getDistanceAndDuration() async {
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    String waypointsString = activeWaypoints.map((wp) => wp.location).join('|');
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${destination!.latitude},${destination!.longitude}&waypoints=optimize:true|$waypointsString&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        var legs = data['routes'][0]['legs'];
        double totalDistance = 0;
        double totalDuration = 0;
        for (var leg in legs) {
          totalDistance += leg['distance']['value'];
          totalDuration += leg['duration']['value'];
        }
        String distanceText = '${(totalDistance / 1000).toStringAsFixed(1)} km';
        String durationText = '${(totalDuration / 60).toStringAsFixed(0)} mins';
        setState(() {
          distance = distanceText;
          duration = durationText;
        });
      }
    }
  }

  // Directions API request for the next waypoint distance/duration and navigation steps
  Future<void> getWaypointDistanceandDuration(
      LocationData? currentLocation, PolylineWayPoint waypoint) async {
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation.longitude!);
    LatLng waypointLatLng = LatLng(
      double.parse(waypoint.location.split(',')[0]),
      double.parse(waypoint.location.split(',')[1]),
    );
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${waypointLatLng.latitude},${waypointLatLng.longitude}&mode=driving&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final leg = data['routes'][0]['legs'][0];
        setState(() {
          waypointDistance = leg['distance']['text'];
          waypointDuration = leg['duration']['text'];
        });
        List<Map<String, dynamic>> stepsList = [];
        for (var step in leg['steps']) {
          String instruction =
              step['html_instructions'].replaceAll(RegExp(r'<[^>]*>'), '');
          double stepDistance = step['distance']['value'].toDouble();
          stepsList.add({
            'instruction': instruction,
            'distance': stepDistance,
          });
        }
        setState(() {
          navigationSteps = stepsList;
          currentStepIndex = 0;
        });
      }
    }
  }

  // Trim the polyline as the user moves
  void trimPolyline(LatLng userLocation) {
    if (polylineCoordinates.isEmpty) return;
    int closestIndex = findClosestPointIndex(userLocation, polylineCoordinates);
    setState(() {
      polylineCoordinates = polylineCoordinates.sublist(closestIndex);
    });
  }

  // Add markers for waypoints, destination, and current location
  void addMarkers() {
    markers.clear();
    var destinationId = SightProvider().sights.length - 1;
    for (int i = 0; i < waypoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('$i'),
          position: waypoints[i],
          infoWindow: InfoWindow(title: 'Waypoint $i'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    markers.add(
      Marker(
        markerId: MarkerId('$destinationId'),
        position: destination!,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        ),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load dark map style from assets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DefaultAssetBundle.of(context)
          .loadString('assets/map_styles/dark_mode.json')
          .then((string) {
        setState(() {
          _mapStyle = string;
        });
      });
    });
    // Fetch sight mode data and assign points
    fetchSightMode(widget.docId).then((data) {
      setState(() {
        sightMode = data;
        isLoading = false;
      });
      assignPoints(sightMode!, updateAssignPointsState, context);
      addMarkers();
      setState(() {
        isDataLoaded = true;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching sight mode: $error");
    });
    getCurrentLocation();
    getDistanceAndDuration();
  }
// Update the loading states in the build method
@override
Widget build(BuildContext context) {
  // Show loading indicator until data is ready
  if (isLoading) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030A0E),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadingIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Initializing Navigation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (sightMode == null) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030A0E),
        ),
        child: Center(
          child: Text(
            "Failed to load sight mode data.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  if (!isDataLoaded || sourceLocation == null || destination == null) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030A0E),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadingIndicator(),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    "Source Location: ${sourceLocation ?? "Loading..."}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    "Destination: ${destination ?? "Loading..."}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

    if (!isDataLoaded || sourceLocation == null || destination == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Column(
                children: [
                  Text("Source Location: ${sourceLocation ?? "Loading..."}"),
                  Text("Destination: ${destination ?? "Loading..."}"),
                  Text("Waypoints: ${waypoints.isNotEmpty ? waypoints : "Loading..."}"),
                  Text("isDataLoaded: $isDataLoaded"),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          if (currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 15.5,
              ),
              markers: markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.lightBlue,
                  width: 6,
                  zIndex: -1,
                )
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
                mapController.setMapStyle(_mapStyle);
              },
            ),
          // Top Instruction Panel (glass panel) - shows only the current navigation instruction with remaining step distance
          Positioned(
            top: kToolbarHeight + 20,
            left: 20,
            right: 20,
            child: _buildGlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Instruction',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    navigationSteps.isNotEmpty && currentStepIndex < navigationSteps.length
                        ? "${navigationSteps[currentStepIndex]['instruction']} in ${navigationSteps[currentStepIndex]['distance'].toInt()}m"
                        : "You have arrived!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Bottom Info Panel (glass panel) - shows overall route info and next waypoint info
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildGlassPanel(
              child: Column(
                children: [
                  _buildInfoRow('Total Distance', distance),
                  _buildInfoRow('Estimated Duration', duration),
                  const Divider(color: Colors.white24),
                  _buildInfoRow('Next Waypoint Distance', waypointDistance),
                  _buildInfoRow('Next Waypoint ETA', waypointDuration),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ),
          ),
        ],
      ),
    );
  }
}
  // Reusable glass panel widget with blur effect
  Widget _buildGlassPanel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Reusable info row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
