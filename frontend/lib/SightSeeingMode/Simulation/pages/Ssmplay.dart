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
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';
import 'package:practice/SightSeeingMode/Simulation/services/TrimPolyline.dart';
import 'package:practice/SightSeeingMode/Simulation/services/assignPoints.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';
import 'package:practice/SightSeeingMode/Simulation/services/checkProximity.dart';
import 'package:practice/SightSeeingMode/Simulation/services/PolylineThresholdCheck.dart';

class SsmPlay extends StatefulWidget {
  
  //widget takes the index as a parameter to figure out the sightseeing mode id
  final int index;

  //widget takes the doc id of the sight
  final String docId;

  const SsmPlay({Key? key, required this.index, required this.docId})
      : super(key: key);

  @override
  State<SsmPlay> createState() => SsmPlayState();
}

class SsmPlayState extends State<SsmPlay> {
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

  //track the internet connection status
  String _connectionStatus = 'Unknown';

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

  //stores the current location as in lat and lang (Location package)
  LocationData? currentLocation;

  //distance and duration holders (for the distanced matrix api response)
  String distance = '';
  String duration = '';

  //distance and duration holders (for the direction api request for waypoints)
  String waypointDistance = "";
  String waypointDuration = "";

  //custom marker variables (Bitmap descriptor)
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

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

  //function to get the current location (using the location package)
  void getCurrentLocation() async {
    //hold the current location
    Location location = Location();
    //get the current location using getlocation and uses then to handle the result (Location package)
    location.getLocation().then(
      (location) {
        setState(() {
          //set the current location to the obtained location
          currentLocation = location;
        });
        //call getPolyPoints after a obtaining the current location
        getPolyPoints();
      },
    );
    //waits for the google map controller to be available
    GoogleMapController googleMapController = await _controller.future;

    //listens to the stream function onLocationChanged in location package and a callback function everytime location changes
    location.onLocationChanged.listen((newLoc) {
      //current Location changes to newLocation
      setState(() {
        currentLocation = newLoc;
      });
      
      //trim the polyline
      trimPolyline(LatLng(newLoc.latitude!, newLoc.longitude!));

      //checks the proximity everytime the location changes
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
      if (!isLocationWithinPolylineThreshold(
          currentLatLng, polylineCoordinates, 50.0)) {
        // Redraw the polyline if the location is outside the threshold
        getPolyPoints();
      }

      //Recalculate the polyline with updated location
      // getPolyPoints();

      //call the waypoint distance and duration calculator using current locaton anf the first active waypoint
      getWaypointDistanceandDuration(currentLocation, activeWaypoints[0]);

      //call the current locaton to destination distance matrix api request (full sightseeing mode duration and distance)
      getDistanceAndDuration();

      //dynamically update the navigation steps
      if (navigationSteps.isEmpty || currentStepIndex >= navigationSteps.length)
        return;

      LatLng userLatLng = LatLng(newLoc.latitude!, newLoc.longitude!);

      //Update current step's distance
      double distanceToStep = calculateDistance(
          userLatLng, navigationSteps[currentStepIndex]['distance']);

      setState(() {
        navigationSteps[currentStepIndex]['distance'] = distanceToStep;
      });

      //If user reaches the step, move to the next step
      if (distanceToStep < 10) {
        setState(() {
          //Move to the next instruction
          currentStepIndex++;
        });
      }

      //change the animate Camera of the controller to the new location
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
            zoom: 15.5 //fixed zoom level
            ),
      ));

      //call the setState which includes a set of functions
      // setState(() {});
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
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(destination!.latitude, destination!.longitude),
        travelMode: TravelMode.driving,
        wayPoints: activeWaypoints);

    //if the results are not empty add the co-ordinates to the polylineCoordinates array containing lat and lang points

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = [];
      result.points.forEach((PointLatLng point) {
        routePoints.add(LatLng(point.latitude, point.longitude));
      });

      var alertMessage3 = routePoints.toString();

      setState(() {
        polylineCoordinates = routePoints;
      });

      // showAlertDialog2(alertMessage3);

      //Snap the route coordinates to the nearest road
      // await snapToRoads(routePoints);
    }

    //call set state which has many functions
    // setState(() {});
  }

  //distance matrix api request for the sightseeing route
  Future<void> getDistanceAndDuration() async {
    //convert current location into a lat lang object
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    //url with location coorindates
    //get distancea and duration between the current location and the destination
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentLatLng.latitude!},${currentLatLng.longitude!}&destinations=${destination!.latitude},${destination!.longitude}&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    //get request to distance matrix api
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      //call set state
      setState(() {
        //extract the details from the response
        distance = data['rows'][0]['elements'][0]['distance']['text'];
        duration = data['rows'][0]['elements'][0]['duration']['text'];
      });
    } else {
      print("Failed to get distance and duration");
    }
  }

  //distance and duration to the nearest waypoint using directions api*
  Future<void> getWaypointDistanceandDuration(
      LocationData? currentLocation, PolylineWayPoint waypoint) async {
    //convert current location into a lat lang object
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    //convert the PolylineWaypoint object into a lat lang object
    LatLng WaypointlatLng = LatLng(
      double.parse(waypoint.location.split(',')[0]),
      double.parse(waypoint.location.split(',')[1]),
    );

    //directions api request
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${WaypointlatLng.latitude},${WaypointlatLng.longitude}&mode=driving&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        final legs = data['routes'][0]['legs'][0];

        setState(() {
          waypointDistance = legs['distance']['text'];
          waypointDuration = legs['duration']['text'];
        });

        print('Distance: $waypointDistance, Duration: $waypointDuration');

        //Extract step-by-step navigation instructions
        List<Map<String, dynamic>> stepsList = [];
        for (var step in legs['steps']) {
          //Remove HTML tags
          String instruction =
              step['html_instructions'].replaceAll(RegExp(r'<[^>]*>'), '');
          //Distance in meters
          double distance = step['distance']['value'].toDouble();

          stepsList.add({
            'instruction': instruction,
            'distance': distance,
          });
        }
        //Store navigation steps
        setState(() {
          navigationSteps = stepsList;
          //Start from first step
          currentStepIndex = 0;
        });

        print("Navigation Steps: $navigationSteps");
      } else {
        print("Failed to fetch waypoint distance & duration.");
      }
    }
  }

  //trim the polylines as the user moves
  void trimPolyline(LatLng userLocation) {
    if (polylineCoordinates.isEmpty) return;

    int closestIndex = findClosestPointIndex(userLocation, polylineCoordinates);

    setState(() {
      polylineCoordinates = polylineCoordinates.sublist(closestIndex);
    });
  }

  // Function to add markers for waypoints and destination
  void addMarkers() {
    markers.clear();
    // Add markers for waypoints
    for (int i = 0; i < waypoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: waypoints[i],
          infoWindow: InfoWindow(title: 'Waypoint ${i + 1}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add marker for destination
    markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: destination!,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    var locationString = currentLocation!.latitude.toString();

    showAlertDialog2(context, locationString);

    //add marker for current location
    markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        infoWindow: InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  //init state
  @override
  void initState() {
    super.initState();
    // Fetch sight mode data
    fetchSightMode(widget.docId).then((data) {
      if (data != null) {
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
      } else {
        setState(() {
          isLoading = false; // Data is null, set loading to false
        });
        print("Fetched data is null");
      }
    }).catchError((error) {
      setState(() {
        isLoading = false; // Error occurred, set loading to false
      });
      print("Error fetching sight mode: $error");
    });
    getCurrentLocation();
    // setCustomMarkerIcon();

    // getPolyPoints();
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
          currentLocation == null
              ? const Center(child: Text("Loading"))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Colors.lightBlue,
                      width: 6,
                    )
                  },
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                ),
          Positioned(
            bottom: 10,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _connectionStatus,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text("Distance: $distance", style: TextStyle(fontSize: 16)),
                  Text("Duration: $duration", style: TextStyle(fontSize: 16)),
                  Divider(),
                  Text("Waypoint Distance: $waypointDistance",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  Text("Waypoint Duration: $waypointDuration",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom:
                750, //You can adjust the position to not overlap with the other widget
            left: 0,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                navigationSteps.isNotEmpty &&
                        currentStepIndex < navigationSteps.length
                    ? "${navigationSteps[currentStepIndex]['instruction']} in ${navigationSteps[currentStepIndex]['distance'].toInt()}m"
                    : "Arrived at destination",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
