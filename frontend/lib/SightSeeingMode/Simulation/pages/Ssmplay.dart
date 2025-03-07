import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/Services/SightGet.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Navigation.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/mapbox.dart';
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';

class SsmPlay extends StatefulWidget {
  //widget takes the index as a parameter to figure out the sightseeing mode id
  final int index;

  const SsmPlay({Key? key, required this.index}) : super(key: key);

  @override
  State<SsmPlay> createState() => SsmPlayState();
}

class SsmPlayState extends State<SsmPlay> {
  //store the recieved sightseeing data in a Map
  Map<String, dynamic>? sightMode;

  //Store reached near waypoints to avoid duplicate alerts (when you are near a waypoint)
  Set<LatLng> reachedNearWaypoints = {};

  //Store reached waypoints to avoid duplicate alerts (when you reached a waypoint)
  Set<LatLng> reachedWaypoints = {};

  //Google map instance as a completer
  final Completer<GoogleMapController> _controller = Completer();

  //temporary holders for the sourcelocation and destination
  static const LatLng sourceLocation = LatLng(6.928684, 79.878155);
  static const LatLng destination = LatLng(6.922409, 79.866084);

  //store the navigation steps recieved from the Directions waypoint api request
  List<Map<String, dynamic>> navigationSteps = [];

  //track the current step
  int currentStepIndex = 0;

  //list of lat and lang co-ordinates to hold the polyline coordinates
  List<LatLng> polylineCoordinates = [];

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

      //checks the proximity everytime the location changes
      checkProximityAndNotify();

      //Recalculate the polyline with updated location
      getPolyPoints();

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

  //function to check the navigation steps(directions api)
  void startTrackingLocation() {}

  //Check if the user is within 200 meters of the destination and show an alert dialog if true
  void checkProximityAndNotify() {
    //if the currentLocation has no location value return
    if (currentLocation == null) return;

    //List of LatLng objects containing coordinates of the waypoints (dummy)
    List<LatLng> waypoints = [
      LatLng(6.928684, 79.878155),
    ];

    //boolean value to store if the alert is shown
    bool alertShown = false;

    //for every waypoint in all the waypoints
    for (LatLng waypoint in waypoints) {
      //calculate distance to a waypoint from the current location using the haverSince calculation
      double distanceToWaypoint = calculateDistance(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        waypoint,
      );

      //if the obtained distance to the waypoint from current location is less than 200
      if (distanceToWaypoint <= 200 &&
          !reachedNearWaypoints.contains(waypoint)) {
        //show that you are near a waypoint
        showAlertDialog("You are near a waypoint!");

        //mark the waypoint as a reached near one to avoid duplication
        reachedNearWaypoints.add(waypoint);

        //alert will show up
        alertShown = true;
      }

      //if the obtained distance to the waypoint from current location is less than 50
      if (distanceToWaypoint <= 50 && !reachedWaypoints.contains(waypoint)) {
        //show that you have arrived at a waypoint
        showAlertDialog("You have arrived at a waypoint!");

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
      destination,
    );

    //if the distance is less than 50 meteres display you have arrived
    if (distanceToDestination <= 50) {
      showAlertDialog("You have arrived at your destination!");
    }

    //if the distance is less than 200 display you are near the destination
    if (distanceToDestination <= 200) {
      showAlertDialog("You are near the destination!");
    }
  }

  //Show an AlertDialog with the specified message
  void showAlertDialog(String message) {
    // Check if the widget is still mounted before showing dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Alert"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  //function to get the polypoints
  void getPolyPoints() async {
    //if current location is null return
    if (currentLocation == null) return;

    //new polyline object (polyline)
    PolylinePoints polylinePoints = PolylinePoints();

    //clear exsiting polylines
    polylineCoordinates.clear();

    //Define waypoints excluding reached ones
    activeWaypoints = [
      PolylineWayPoint(
          location: "${sourceLocation.latitude},${sourceLocation.longitude}")
    ].where((wp) {
      LatLng wpLatLng = LatLng(
        double.parse(wp.location.split(',')[0]),
        double.parse(wp.location.split(',')[1]),
      );
      return !reachedWaypoints.contains(wpLatLng);
    }).toList();

    //receieve polylines using getRoutebetween function of directions api
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0',
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
        wayPoints: activeWaypoints);

    //if the results are not empty add the co-ordinates to the polylineCoordinates array containing lat and lang points

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = [];
      result.points.forEach((PointLatLng point) {
        routePoints.add(LatLng(point.latitude, point.longitude));
      });

      //Snap the route coordinates to the nearest road
      await snapToRoads(routePoints);
    }

    //call set state which has many functions
    setState(() {});
  }

  //Use google ROADS API to snap polyline coorindates to the nearest road
  Future<void> snapToRoads(List<LatLng> routePoints) async {
    //get the path of all the coordinates of the path and snap it to the nearest road
    String waypoints = routePoints
        .map((LatLng point) => '${point.latitude},${point.longitude}')
        .join('|');

    String url =
        'https://roads.googleapis.com/v1/snapToRoads?path=$waypoints&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<LatLng> snappedCoordinates = [];

      for (var snappedPoint in data['snappedPoints']) {
        double lat = snappedPoint['location']['latitude'];
        double lng = snappedPoint['location']['longitude'];
        snappedCoordinates.add(LatLng(lat, lng));
      }

      //set the polyline coordinates to snapped coordinates
      setState(() {
        polylineCoordinates = snappedCoordinates;
      });
    } else {
      print("Failed to snap to roads: ${response.statusCode}");
    }
  }

  //distance matrix api request for the sightseeing route
  Future<void> getDistanceAndDuration() async {
    //convert current location into a lat lang object
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    //url with location coorindates
    //get distancea and duration between the current location and the destination
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentLatLng.latitude!},${currentLatLng.longitude!}&destinations=${destination.latitude},${destination.longitude}&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

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

  //distance and duration to the nearest waypoint using directions api
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

  //function to set the custom marker
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/profile.jpg")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/profile.jpg")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/profile.jpg")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
  }

  //init state
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    getDistanceAndDuration();
    fetchSightMode(widget.index).then((data) {
      setState(() {
        sightMode = data;
      });
    }).catchError((error) {
      print("Error fetching sight mode: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
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
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Colors.lightBlue,
                      width: 6,
                    )
                  },
                  markers: {
                    Marker(
                        markerId: const MarkerId("currentLocation"),
                        icon: currentLocationIcon,
                        position: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!)),
                    const Marker(
                      markerId: MarkerId("source"),
                      position: sourceLocation,
                    ),
                    const Marker(
                      markerId: MarkerId("destination"),
                      position: destination,
                    )
                  },
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                ),
          Positioned(
            bottom: 20,
            left: 20,
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
                  Text("Distance: $distance", style: TextStyle(fontSize: 16)),
                  Text("Duration: $duration", style: TextStyle(fontSize: 16)),
                  Divider(),
                  Text("Waypoint Distance: $waypointDistance",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  Text("Waypoint Duration: $waypointDuration",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  // ElevatedButton(
                  //   onPressed:(){
                  //    // Navigate to MapboxPage when button is pressed
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => NavigationSample()),
                  //     );
                  // },
                  // child:  Text("Go to Mapbox Page"),
                  // )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80, //You can adjust the position to not overlap with the other widget
            left: 20,
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
                navigationSteps.isNotEmpty && currentStepIndex < navigationSteps.length
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
