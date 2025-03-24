import 'dart:async';
import 'dart:ui';
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
  final String? apiKey;

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

  //map styles 
  String _mapStyle='';
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
    _placesService = PlaceAutoCompleteService(apiKey: widget.apiKey!);
    DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/dark_mode.json')
        .then((string) {
      setState(() {
        _mapStyle = string;
      });
    });
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
      placeDetails = await Placedetailservice(apiKey: widget.apiKey!)
          .getPlaceDetails(prediction.placeId);

      // Fetch the image URLs
      imageUrls = LocationInfo.getImageUrlsFromPhotos(
        placeDetails.images,
        widget.apiKey!,
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
        imageUrls: imageUrls,
        description: 'describe this location',
        tags: ["selectedLocation", "SriLanka"],
        name: prediction.mainText);

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
  return Scaffold(
    backgroundColor: const Color(0xFF030A0E),
    body: SafeArea(
      child: Stack(
        children: [
          // Map and Controls Section (when search is not active)
          if (!_isSearchActive && _selectedLocation != null)
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation!,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  controller.setMapStyle(_mapStyle);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _selectedLocation!,
                    infoWindow: const InfoWindow(title: 'Selected Location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                  ),
                },
              ),
            ),

          // Predictions List (when search is active)
          if (_isSearchActive && _predictions.isNotEmpty)
            Positioned(
              // Position it below the search bar
              top: MediaQuery.of(context).padding.top + 80,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onPlaceSelected(prediction),
                            splashColor: Colors.white.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prediction.mainText,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    prediction.secondaryText,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14),
                                  ),
                                  if (index != _predictions.length - 1)
                                    Divider(
                                        height: 24,
                                        color: Colors.white.withOpacity(0.1)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          // Confirm Button & Image Carousel (over the map)
          if (!_isSearchActive && _selectedLocation != null)
            Positioned.fill(
              child: Stack(
                children: [
                  // Confirm Button
                  if (_showCheckmark)
                    Positioned(
                      bottom: 140,
                      right: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Provider.of<SelectedPlaceProvider>(context,
                                        listen: false)
                                    .addLocationInfo(_selectedPlace);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SightMenu(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Image Carousel
                  if (_selectedPlace != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPlace.imageUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _selectedPlace.imageUrls[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    return progress == null
                                        ? child
                                        : Container(
                                            color: Colors.black.withOpacity(0.3),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Search Bar - Positioned at the top
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 80,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: TextField(
                            controller: _controller,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: widget.hint ?? "Search for a place",
                              hintStyle: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back Button - Positioned at the top left
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}