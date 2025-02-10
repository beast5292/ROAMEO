import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/Menu.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
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
          'photo': File(pickedImage.path),
          'location': position,
        };

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
      appBar: AppBar(title: const Text("Camera with GPS Example")),
      body: Consumer<SelectedImageProvider>(
        builder: (context, selectedImageProvider, child) {
          return tempImages.isEmpty
              ? const Center(child: Text("No photos captured"))
              : GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: tempImages.length,
                  itemBuilder: (context, index) {

                    //single image object
                    var image = tempImages[index];

                    return Column(
                      children: [
                        Image.file(
                          image['photo'],
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                        Text(
                          'Lat: ${image['location'].latitude.toStringAsFixed(2)}\n'
                          'Lon: ${image['location'].longitude.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),

                          //remove image from tempImages array by insex on the delete icon press
                          onPressed: () {
                            setState(() {
                              tempImages.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
        },
      ),

       // Floating action button to open the camera
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openCamera,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),

          //check mark button
          FloatingActionButton(
            onPressed: () {
              if (tempImages.isNotEmpty) {

                //adds the temp images array to the provider as an array object
                Provider.of<SelectedImageProvider>(context, listen: false)
                    .addTrip(List.from(tempImages));

                //make temp images array clear
                setState(() {
                  tempImages.clear();
                });

                Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SightMenu()),
                        );
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.check),
          ),
        ],
      ),
      
    );
  }
}
