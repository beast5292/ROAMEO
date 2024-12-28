import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {

  @override
  _CameraPageState createState() => _CameraPageState();

}

class _CameraPageState extends State<CameraPage> {

  //Store key-value pairs (photo and location)
  final List<Map<String, dynamic>> _photosWithLocations = [];
  final ImagePicker _picker = ImagePicker();

  //Function to fetch GPS location

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  
  //function to open the camera and get the picture
  Future<void> _openCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      try {
        Position position = await _getCurrentLocation();
        setState(() {
          _photosWithLocations.add({
            'photo': File(pickedImage.path), // Photo
            'location': position, // GPS Location
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera with GPS Example"),
      ),
      body: _photosWithLocations.isEmpty
          ? const Center(child: Text("No photos captured"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _photosWithLocations.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    //Display the captured photo
                    Image.file(
                      _photosWithLocations[index]['photo'],
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),

                    //Display the location under the photo
                    Text(
                      'Lat: ${_photosWithLocations[index]['location'].latitude.toStringAsFixed(2)}\n'
                      'Lon: ${_photosWithLocations[index]['location'].longitude.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: _openCamera,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.camera_alt, size: 30),
        ),
      ),
    );
  }
}
