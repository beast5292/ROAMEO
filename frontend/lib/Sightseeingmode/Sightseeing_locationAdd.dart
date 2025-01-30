import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class LocationAdd extends StatefulWidget {
  const LocationAdd({super.key});

  @override
  State<LocationAdd> createState() => _LocationAddState();
}

class _LocationAddState extends State<LocationAdd> {
  static const initialPosition = LatLng(37.4223, -122.0848);
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final places = GoogleMapsPlaces(apiKey: "YOUR_API_KEY_HERE");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search & Select Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Search Bar
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to search for a location and move the map
  Future<void> _searchLocation() async {
    
    final query = _searchController.text;
    if (query.isEmpty) return;

    final response = await places.searchByText(query);
    if (response.status == "OK" && response.results.isNotEmpty) {
      final place = response.results.first;
      final latLng = LatLng(place.geometry!.location.lat, place.geometry!.location.lng);

      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }
}
