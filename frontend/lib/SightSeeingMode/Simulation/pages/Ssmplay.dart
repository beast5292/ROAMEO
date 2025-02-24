import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/Services/SightGet.dart';
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';

class SsmPlay extends StatefulWidget {
  final int index;

  const SsmPlay({Key? key, required this.index}) : super(key: key);

  @override
  State<SsmPlay> createState() => SsmPlayState();
}

class SsmPlayState extends State<SsmPlay> {
  //store the recieved sight
  Map<String, dynamic>? sightMode;

  // Store reached near waypoints to avoid duplicate alerts
  Set<LatLng> reachedNearWaypoints = {};

  // Store reached waypoints to avoid duplicate alerts
  Set<LatLng> reachedWaypoints = {};

  //Google map instance as a completer
  final Completer<GoogleMapController> _controller = Completer();

  //temporary holders for the sourcelocation and destination
  static const LatLng sourceLocation = LatLng(6.928684, 79.878155);
  static const LatLng destination = LatLng(6.922409, 79.866084);

  //list of lat and lang co-ordinates to hold the polyline coordinates
  List<LatLng> polylineCoordinates = [];

  //stores the current location as in lat and lang (Location package)
  LocationData? currentLocation;

  //distance and duration holders
  String distance = '';
  String duration = '';

  //custom marker variables (Bitmap descriptor)
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  //function to get the current location (using the location package)
  void getCurrentLocation() async {
    //hold the current location
    Location location = Location();

    //get the current location using getlocation and uses then to handle the result
    location.getLocation().then(
      (location) {
        setState(() {
          //set the current location to the obtained location
          currentLocation = location;
        });

        getPolyPoints();
      },
    );

    //waits for the google map controller to be available
    GoogleMapController googleMapController = await _controller.future;

    //listens to the stream function onLocationChanged and a callback function everytime location changes
    location.onLocationChanged.listen((newLoc) {
      //current Location changes to newLocation
      setState(() {
        currentLocation = newLoc;
      });

      checkProximityAndNotify();

      // Recalculate the polyline with updated location
      getPolyPoints();

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

  // Check if the user is within 200 meters of the destination and show an alert dialog if true
  void checkProximityAndNotify() {
    if (currentLocation == null) return;

    List<LatLng> waypoints = [
      LatLng(6.928684, 79.878155), // Example waypoint 1
    ];

    bool alertShown = false; // Prevent multiple stacked dialogs

    for (LatLng waypoint in waypoints) {
      double distanceToWaypoint = calculateDistance(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        waypoint,
      );

      if (distanceToWaypoint <= 200 &&
          !reachedNearWaypoints.contains(waypoint)) {
        showAlertDialog("You are near a waypoint!");
        reachedWaypoints.add(waypoint); // Mark waypoint as notified
        alertShown = true;
      }

      if (distanceToWaypoint <= 50 && !reachedWaypoints.contains(waypoint)) {
        showAlertDialog("You have arrived at a waypoint!");
        reachedWaypoints.add(waypoint);
        
        //redraw polylines without the arrived waypoints
        getPolyPoints();
        alertShown = true;
      }

      if (alertShown) return; // Exit loop after showing an alert
    }

    double distanceToDestination = calculateDistance(
      LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      destination,
    );

    if (distanceToDestination <= 50) {
      showAlertDialog("You have arrived at your destination!");
    }

    if (distanceToDestination <= 200) {
      showAlertDialog("You are near the destination!");
    }
  }

  // Show an AlertDialog with the specified message
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
    if (currentLocation == null) return;

    //new polyline object (polyline)
    PolylinePoints polylinePoints = PolylinePoints();

    //clear exsiting polylines
    polylineCoordinates.clear();

    // Define waypoints excluding reached ones
    List<PolylineWayPoint> activeWaypoints = [
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

      // Snap the route coordinates to the nearest road
      await snapToRoads(routePoints);
    }
    //call set state
    setState(() {});
  }

  //Use google ROADS API to snap polyline coorindates to the nearest road

  // Use Google Roads API to snap polyline coordinates to the nearest road
  Future<void> snapToRoads(List<LatLng> routePoints) async {
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

      setState(() {
        polylineCoordinates = snappedCoordinates;
      });
    } else {
      print("Failed to snap to roads: ${response.statusCode}");
    }
  }

  //distance matrix api request
  Future<void> getDistanceAndDuration() async {
    //url with location coorindates
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentLocation!.latitude!},${currentLocation!.longitude!}&destinations=${destination.latitude},${destination.longitude}&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
