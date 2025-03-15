import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/Menu.dart';
import 'package:practice/SightSeeingMode/location_select/services/autoCService.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:provider/provider.dart';
import 'package:practice/SightSeeingMode/location_select/services/placeDetailService.dart';

class PlacesAutoCompleteField extends StatefulWidget {
  //api key
  final String apiKey;

  final String? hint;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final String? types;

  //constructor
  const PlacesAutoCompleteField({
    Key? key,
    required this.apiKey,
    this.hint,
    this.latitude,
    this.longitude,
    this.radius,
    this.types,
  }) : super(key: key);

  @override
  State<PlacesAutoCompleteField> createState() =>
      _PlacesAutoCompleteFieldState();
}

class _PlacesAutoCompleteFieldState extends State<PlacesAutoCompleteField> {
  //to get the search bar text
  final TextEditingController _controller = TextEditingController();

  //store a list of placePrediction objects in a predictions array
  List<PlacePrediction> _predictions = [];

  //API service instance
  late PlaceAutoCompleteService _placesService;

  // Timer for debouncing API calls
  Timer? _debounce;

  GoogleMapController? _mapController;

  LatLng? _selectedLocation;

  //track search status
  bool _isSearchActive = false;

  //track checkmark status
  bool _showCheckmark = false;

  //hold the selected place
  var _selectedPlace;

  //instantiating the class by making a new ServiceObject
  @override
  void initState() {
    super.initState();
    _placesService = PlaceAutoCompleteService(apiKey: widget.apiKey);
  }

  //cleaning up text controller and widget state
  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String input) {
    //timer debouncing the api calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (input.length > 1) {
        try {
          final predictions =
              await _placesService.getPlacePrediction(input: input);
          setState(() {
            _predictions = predictions;
            _isSearchActive = true;
          });
        } catch (e) {
          print("Error fetching predictions: $e");
        }
      } else {
        setState(() => _predictions = []);
        _isSearchActive = false;
      }
    });
  }

  void _onPlaceSelected(PlacePrediction prediction) async {
    var placeDetails;

    List<String> imageUrls = [];

    //fetch the place details for the selected prediction
    try {
      placeDetails = await Placedetailservice(apiKey: widget.apiKey)
          .getPlaceDetails(prediction.placeId);

      // Fetch the image URLs
      imageUrls = LocationInfo.getImageUrlsFromPhotos(
        placeDetails.images,
        widget.apiKey,
      );

      print(
          'Place Details: ${placeDetails.name}, ${placeDetails.latitude}, ${placeDetails.longitude}, ${placeDetails.address}');
    } catch (e) {
      print("Error fetching place details");
    }

    //creating location info object
    final locationinfo = LocationInfo(
        prediction: prediction,
        placeDetails: placeDetails,
        imageUrls: imageUrls);

    //Assigning the selected location object to selectedPlace
    _selectedPlace = locationinfo;

    // Update text field with full description
    _controller.text = prediction.description;

    // Clear predictions list
    setState(() {
      _predictions = [];
      _isSearchActive = false;
      //settings the selected location
      _selectedLocation = LatLng(placeDetails.latitude, placeDetails.longitude);
      _showCheckmark = true;
    });

    //updating the focus of the camera
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search for a place',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
        if (_isSearchActive && _predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction.mainText),
                  subtitle: Text(prediction.secondaryText),
                  onTap: () => _onPlaceSelected(prediction),
                );
              },
            ),
          ),
        if (!_isSearchActive && _selectedLocation != null)
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId('selected_location'),
                      position: _selectedLocation!,
                      infoWindow: InfoWindow(title: 'Selected Location'),
                    ),
                  },
                ),
                if (_showCheckmark)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Add location info to the provider
                        final placeProvider =
                            Provider.of<SelectedPlaceProvider>(context,
                                listen: false);
                        placeProvider.addLocationInfo(_selectedPlace);
                        print(_selectedPlace.toString());
                        setState(() {
                          _showCheckmark = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SightMenu()),
                        );
                      },
                      child: Icon(Icons.check),
                    ),
                  ),
                // Displaying images below the map
                if (_selectedPlace != null)
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: (_selectedPlace.imageUrls as List<String>)
                          .map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  )
              ],
            ),
          ),
      ],
    ));
  }
}
