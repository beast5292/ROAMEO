import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/Menu.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  //Array to store the temporary images taken per session
  List<Map<String, dynamic>> tempImages = [];

  //open camera function
  Future<void> _openCamera() async {
    //store the picked image file by source reference using image picker
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);

    //if the picked image is not null obtain the current location using geolocator
    if (pickedImage != null) {
      try {
        Position position = await _getCurrentLocation();

        print(position);

        //image Data object combining the picture file and the location
        var imageData = {
          'photo': pickedImage.path,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'name': "Unknown",
          'description': "describe this location",
          'tags': ["capturedLocations", "SriLanka"]
        };

        print(imageData);

        //add the image data object to the temp Images array
        setState(() {
          tempImages.add(imageData);
        });
      } catch (e) {
        //show an error message if location is not fetched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
    }
  }

  //Function returning the current location using Geolocator, returns a position object
  Future<Position> _getCurrentLocation() async {
    //checking if the service permissions are enabled in the manifest
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    //checking if the service permissions are enabled in the manifest
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    //checking if the service permissions are enabled in the manifest
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    //return a position object using getCurrentPosition, contains lan and long co-ordinates
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    //returning object structure
    // {
    //   latitude: value
    //   longitude: value
    // }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A0E),
      appBar: AppBar(
        title: const Text("Geo-Tagged Photos", 
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SelectedImageProvider>(
          builder: (context, selectedImageProvider, child) {
            return tempImages.isEmpty
                ? const Center(
                    child: Text(
                      "No photos captured", 
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: tempImages.length,
                    itemBuilder: (context, index) {
                      final image = tempImages[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: FileImage(File(image['photo'])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_rounded, 
                                          color: Colors.red.withOpacity(0.8)),
                                        onPressed: () => setState(() => tempImages.removeAt(index)),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Lat: ${image['latitude'].toStringAsFixed(5)}\n'
                                    'Lon: ${image['longitude'].toStringAsFixed(5)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );  
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildGlassButton(
            icon: Icons.camera_alt,
            onPressed: _openCamera,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildGlassButton(
            icon: Icons.check,
            onPressed: () {
              if (tempImages.isNotEmpty) {
                Provider.of<SelectedPlaceProvider>(context, listen: false)
                    .addImageInfo(List.from(tempImages));
                setState(() => tempImages.clear());
                Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => const SightMenu()));
              }
            },
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}