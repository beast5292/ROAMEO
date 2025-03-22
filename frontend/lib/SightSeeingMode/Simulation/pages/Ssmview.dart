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
import 'package:practice/SightSeeingMode/Simulation/services/assignPoints.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';


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
          PointLatLng(sourceLocation!.latitude!, sourceLocation!.longitude!),
          PointLatLng(destination!.latitude, destination!.longitude),
          travelMode: TravelMode.driving,
          wayPoints: activeWaypoints,
          optimizeWaypoints: true);

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
    }
    //call set state which has many functions
    // setState(() {});
  

  //distance matrix api request for the sightseeing route
  Future<void> getDistanceAndDuration() async {
    //convert current location into a lat lang object
    LatLng currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    //Prepare the waypoints string for the Directions API request
    String waypointsString = activeWaypoints.map((wp) => wp.location).join('|');

    //Directions API URL with current location, destination, and waypoints
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${destination!.latitude},${destination!.longitude}&waypoints=optimize:true|$waypointsString&key=AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0';

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
            LatLng(sourceLocation!.latitude!, sourceLocation!.longitude!),
        infoWindow: InfoWindow(title: 'Origin'),
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
                      zIndex: -1,
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
            ),
          )
        ],
      ),
    );
  }
}
