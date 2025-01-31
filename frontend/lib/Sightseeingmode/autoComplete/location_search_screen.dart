import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homepage/Sightseeingmode/components/location_list_tile.dart';
import 'package:homepage/Sightseeingmode/components/network_utility.dart';
import 'package:homepage/Sightseeingmode/models/autocomplate_prediction.dart';
import 'package:homepage/Sightseeingmode/models/place_auto_complate_response.dart';

import 'constants.dart';

class SearchLocationScreen extends StatefulWidget {
  
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

final apiKey = "AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0";

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  GoogleMapController? mapController;
  List<AutocompletePrediction> placePredictions = [];
  String? selectedLocation;
  double? selectedLat;
  double? selectedLng;
  bool isSearching = false;

  void placeAutocompleter(String query) async {
    Uri uri = Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": apiKey,
    });

    String? response = await NetworkUtiliti.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/place/details/json", {
      "place_id": placeId,
      "key": apiKey,
    });

    String? response = await NetworkUtiliti.fetchUrl(uri);

    if (response != null) {
      Map<String, dynamic> result = jsonDecode(response);

      double lat = result['result']['geometry']['location']['lat'];
      double lng = result['result']['geometry']['location']['lng'];

      setState(() {
        selectedLocation = result['result']['formatted_address'];
        selectedLat = lat;
        selectedLng = lng;
        isSearching = false; // Hide the search results and show the map
      });

      moveCamera(lat, lng); // Move and zoom the camera to the selected location
    }
  }

  void moveCamera(double lat, double lng) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 200), // Zoom to level 15
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: Icon(
              Icons.location_on,
              color: secondaryColor40LightTheme,
            ),
          ),
        ),
        title: const Text(
          "Set Delivery Location",
          style: TextStyle(color: textColorLightTheme),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          const SizedBox(width: defaultPadding)
        ],
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    isSearching = value.isNotEmpty; // Toggle map visibility
                  });
                  placeAutocompleter(value);
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search your location",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.place,
                      color: secondaryColor40LightTheme,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearching = true; // Always show the search results
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          // Show Google Map only when not searching
          if (!isSearching)
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(6.9271, 79.8612), // Default to Colombo, Sri Lanka
                  zoom: 12,
                ),
                markers: selectedLat != null && selectedLng != null
                    ? {
                        Marker(
                          markerId: MarkerId("selected"),
                          position: LatLng(selectedLat!, selectedLng!),
                          infoWindow: InfoWindow(title: selectedLocation),
                        ),
                      }
                    : {},
              ),
            ),
          // Show autocomplete results when typing or after search icon click
          if (isSearching)
            Expanded(
              child: ListView.builder(
                itemCount: placePredictions.length,
                itemBuilder: (context, index) => LocationListTile(
                  press: () async {
                    String placeId = placePredictions[index].placeId!;
                    await fetchPlaceDetails(placeId);
                  },
                  location: placePredictions[index].description!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}