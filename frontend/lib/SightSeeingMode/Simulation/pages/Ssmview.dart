import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class SsmView extends StatefulWidget {
  //widget takes the index as a parameter to figure out the sightseeing mode id
  final int index;

  //widget takes the doc id of the sight
  final String docId;

  const SsmView({super.key, required this.index, required this.docId});

  @override
  State<SsmView> createState() => SsmViewState();
}

class SsmViewState extends State<SsmView> {
  //loading state variable
  bool isLoading = true;

  //Add a flag to track if data is loaded
  static bool isDataLoaded = true;

  //store the recieved sightseeing data in a Map
  Map<String, dynamic>? sightMode;

  //Store reached near waypoints to avoid duplicate alerts (when you are near a waypoint)
  Set<LatLng> reachedNearWaypoints = {};

  //Store reached waypoints to avoid duplicate alerts (when you reached a waypoint)
  Set<LatLng> reachedWaypoints = {};

  //Google map instance as a completer
  final Completer<GoogleMapController> _controller = Completer();

  //temporary holders for the sourcelocation and destination
  static LatLng? sourceLocation;
  static LatLng? destination;
  static List<LatLng> waypoints = [];

  //store the navigation steps recieved from the Directions waypoint api request
  List<Map<String, dynamic>> navigationSteps = [];

  //track the current step
  int currentStepIndex = 0;

  //list of lat and lang co-ordinates to hold the polyline coordinates
  static List<LatLng> polylineCoordinates = [];

  //define only the active way points
  late List<PolylineWayPoint> activeWaypoints;


  //distance and duration holders (for the directions api response)
  String distance = '';
  String duration = '';

  //custom marker variables (Bitmap descriptor)
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;


  //Set to hold markers
  Set<Marker> markers = {};

  //setState of assignPoints function
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

  

  //function to get the polypoints
  void getPolyPoints() async {
    //new polyline object (polyline)
    PolylinePoints polylinePoints = PolylinePoints();

    //clear exsiting polylines
    polylineCoordinates.clear();

    //Define waypoints excluding reached ones
    activeWaypoints = waypoints
        .where((wp) =>
            !reachedWaypoints.contains(wp)) //Filter out reached waypoints
        .map((wp) => PolylineWayPoint(
              location: "${wp.latitude},${wp.longitude}",
            ))
        .toList();

    // var alertMessage3 = activeWaypoints[0].toString();

    // showAlertDialog2(alertMessage3);

    //receieve polylines using getRoutebetween function of directions api
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0',
        PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
        PointLatLng(destination!.latitude, destination!.longitude),
        travelMode: TravelMode.driving,
        wayPoints: activeWaypoints,
        optimizeWaypoints: true);

    //if the results are not empty add the co-ordinates to the polylineCoordinates array containing lat and lang points
    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = [];
      for (var point in result.points) {
        routePoints.add(LatLng(point.latitude, point.longitude));
      }

      var alertMessage3 = routePoints.toString();

      setState(() {
        polylineCoordinates = routePoints;
      });

      // showAlertDialog2(alertMessage3);

      //Snap the route coordinates to the nearest road
      // await snapToRoads(routePoints);
    }
  }
  //call set state which has many functions
  // setState(() {});

  //directions api request for the sightseeing route
  Future<void> getDistanceAndDuration() async {
    
    //Prepare the waypoints string for the Directions API request
    String waypointsString = activeWaypoints.map((wp) => wp.location).join('|');

    //Directions API URL with current location, destination, and waypoints
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${sourceLocation!.latitude},${sourceLocation!.longitude}&destination=${destination!.latitude},${destination!.longitude}&waypoints=optimize:true|$waypointsString&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    //get request to distance matrix api
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        //Extract the total distance and duration from the first route
        var legs = data['routes'][0]['legs'];
        double totalDistance = 0;
        double totalDuration = 0;

        for (var leg in legs) {
          totalDistance += leg['distance']['value'];
          totalDuration += leg['duration']['value'];
        }

        //Convert distance to kilometers and duration to minutes
        String distanceText = '${(totalDistance / 1000).toStringAsFixed(1)} km';
        String durationText = '${(totalDuration / 60).toStringAsFixed(0)} mins';

        //call set state
        setState(() {
          distance = distanceText;
          duration = durationText;
        });
      } else {
        print("Failed to get distance and duration");
      }
    }
  }


  // Function to add markers for waypoints and destination
  void addMarkers() {

    markers.clear();

    //index for the destination
    var destination_id = SightProvider().sights.length - 1;

    // Add markers for waypoints
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

    // Add marker for destination
    markers.add(
      
      Marker(
        markerId: MarkerId('$destination_id'),
        position: destination!,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // var locationString = currentLocation!.latitude.toString();

    // showAlertDialog2(context, locationString);
  }

  //init state
  @override
  void initState() {
    super.initState();
    // Fetch sight mode data
    fetchSightMode(widget.docId).then((data) {
      setState(() {
        sightMode = data;
        isLoading = false; // Data fetched, set loading to false
        print("sightMode: $sightMode");
      });
      assignPoints(sightMode!, updateAssignPointsState, context);
      addMarkers();
      setState(() {
        isDataLoaded = true;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false; // Error occurred, set loading to false
      });
      print("Error fetching sight mode: $error");
    });
    getDistanceAndDuration();
  }

  //Function to add markers for waypoints and destination
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (sightMode == null) {
      return Scaffold(
        body: Center(
          child: Text("Failed to load sight mode data."),
        ),
      );
    }

    // Show loading indicator until sourceLocation and destination are initialized
    if (!isDataLoaded || sourceLocation == null || destination == null) {
      print("Data not fully loaded - showing progress indicator");
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // Loading indicator
              SizedBox(height: 20), // Spacing
              // Show details if available
              Column(
                children: [
                  Text("Source Location: ${sourceLocation ?? "Loading..."}"),
                  Text("Destination: ${destination ?? "Loading..."}"),
                  Text(
                      "Waypoints: ${waypoints.isNotEmpty ? waypoints : "Loading..."}"),
                  Text("isDataLoaded: $isDataLoaded"),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sightseeing mode",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          sourceLocation == null
              ? const Center(child: Text("Loading"))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(sourceLocation!.latitude,
                        sourceLocation!.longitude),
                    zoom: 13.5,
                  ),
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Colors.lightBlue,
                      width: 6,
                      zIndex: -1,
                    )
                  },
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                ),
          // Positioned(
          //   bottom: 10,
          //   left: 0,
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(8),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black26,
          //           blurRadius: 4,
          //           offset: Offset(2, 2),
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text("Distance: $distance", style: TextStyle(fontSize: 16)),
          //         Text("Duration: $duration", style: TextStyle(fontSize: 16)),
          //         Divider(),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
