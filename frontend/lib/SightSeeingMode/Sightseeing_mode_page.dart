import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Feed/SightFeed.dart';
import 'package:practice/SightSeeingMode/Menu.dart';
import 'package:practice/SightSeeingMode/Services/SightSearch.dart';

//  Import the Firebase Firestore library
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SsmPage extends StatefulWidget {
  const SsmPage({super.key});

  @override
  _SsmPageState createState() => _SsmPageState();
}

class _SsmPageState extends State<SsmPage> {
  static const googlePlex = LatLng(37.4223, -122.0848);
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _showDetails = false;
  String _selectedScenery = 'temporary'; // Default to 'temporary'

  List<Map<String, dynamic>> _searchResults =
      []; // List to store search results
  String? _selectedImage; // Variable to store the selected image

  // TextEditingController for search bar
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //  Method to process search results
  void _performSearch() async {
    String searchQuery = _searchController.text.trim();
    debugPrint("Searching for: $searchQuery");

    if (searchQuery.isNotEmpty) {
      List<Map<String, dynamic>> results = await _searchLocations(searchQuery);
      debugPrint("Search Results Count: ${results.length}");

      setState(() {
        _searchResults = results;
      });
    }
  }

  // Move the map and show the selected location's image
  void _moveToLocation(Map<String, dynamic> location) {
    LatLng position = LatLng(location['latitude'], location['longitude']);

    mapController.animateCamera(CameraUpdate.newLatLng(position));

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(location['name']),
          position: position,
          infoWindow: InfoWindow(title: location['name']),
        ),
      );
      _selectedImage = location['image_url'];
    });
  }

  // Method to fetch locations from database based on search keyword
  Future<List<Map<String, dynamic>>> _searchLocations(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/search_sights/?name=$encodedKeyword'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      debugPrint("Network request failed: $e");
      return [];
    }
  }

  void _loadMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: MarkerId("temporary1"),
          position: LatLng(37.425, -122.08),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () => setState(() => _showDetails = true),
        ),
        Marker(
          markerId: MarkerId("permanent1"),
          position: LatLng(37.42, -122.085),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => setState(() => _showDetails = true),
        ),
      ]);
    });
  }

  // Method to add a marker based on the selected scenery type
  void _addMarker(LatLng position) {
    setState(() {
      final markerId = MarkerId(position.toString());
      final icon = _selectedScenery == 'temporary'
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

      _markers.add(
        Marker(
          markerId: markerId,
          position: position,
          icon: icon,
          onTap: () => setState(() => _showDetails = true),
        ),
      );
    });
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Scenery Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Temporary"),
                leading: Radio(
                  value: "temporary",
                  groupValue: _selectedScenery,
                  onChanged: (value) {
                    setState(() {
                      _selectedScenery = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Permanent"),
                leading: Radio(
                  value: "permanent",
                  groupValue: _selectedScenery,
                  onChanged: (value) {
                    setState(() {
                      _selectedScenery = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(onPressed: () {}, child: const Text("Confirm")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: googlePlex,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: _addMarker, // Allow adding markers by tapping on the map
          ),

          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    // Search bar
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      //focusNode: _seasssssrchFocusNode, // Attach focus node
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        icon: GestureDetector(
                          onTap: _performSearch,
                          child: Icon(Icons.search, color: Colors.white),
                        ),
                      ),

                      onSubmitted: (value) => _performSearch(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display Search results
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 80,
              left: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return ListTile(
                      title: Text(location['name']),
                      onTap: () => _moveToLocation(location),
                    );
                  },
                ),
              ),
            ),

          // Display images when location is selected
          if (_selectedImage != null)
            Positioned(
                bottom: 120,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Image.network(_selectedImage!),
                      Text("Selected Location",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )),

          if (_showDetails)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.network("https://via.placeholder.com/100"),
                    const Text("Beautiful Scenery",
                        style: TextStyle(color: Colors.white)),
                    TextButton(onPressed: () {}, child: const Text("EXPLORE")),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SightMenu()),
                  );
                },
                child: Icon(Icons.create)),
          ),

          Positioned(
            top: 600,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SightFeed()),
                );
              },
              child: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}
