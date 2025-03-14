import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Services/SightsSend.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/models/sight.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

//Make sure to import dart:io for File handling

class SightMenu extends StatefulWidget {
  const SightMenu({super.key});

  @override
  State<SightMenu> createState() => _SightMenuState();
}

class _SightMenuState extends State<SightMenu> {
  //Toggle switch state
  bool showLocations = true;

  Future<String> uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = filePath.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      //Return local path if upload fails
      return filePath;
    }
  }

  onSightSave() async {
    final selectedPlaceProvider =
        Provider.of<SelectedPlaceProvider>(context, listen: false);

    final selectedImageProvider =
        Provider.of<SelectedImageProvider>(context, listen: false);

    //list to hold the Sightseeing mode object
    List<Sight> Sights = [];

    print("Selected Locations: ${selectedPlaceProvider.selectedLocations}");
    print("Selected Images: ${selectedImageProvider.selectedTrips}");

    //iterate through selected locations and create Sight objects
    for (var location in selectedPlaceProvider.selectedLocations) {
      Sight sight = Sight(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Unique ID from the place API
        name: location.prediction.mainText ?? "Unknown Place",
        description:
            location.prediction.secondaryText ?? "No details available",
        tags: [
          "dummyTag",
          "dummyTag2"
        ], // You can modify this to add tags if needed
        lat: location.placeDetails.latitude,
        long: location.placeDetails.longitude,
        imageUrls: location.imageUrls.isNotEmpty ? location.imageUrls : [],
      );

      print(sight.toString());

      Sights.add(sight);
    }

    for (var tripData in selectedImageProvider.selectedTrips) {
      //Extracting image URLs
      List<String> imagePaths = tripData
          .where((imageData) =>
              imageData.containsKey('photo') && imageData['photo'] != null)
          .map<String>((imageData) => imageData['photo'] as String)
          .toList();

      //store the uploaded Urls (jpgs uploaded to the firestorage and google map links)
      List<String> uploadedUrls = [];
      for (String path in imagePaths) {
        if (path.endsWith('.jpg')) {
          //upload the image to firestorage
          String downloadUrl = await uploadImage(path);

          //add the firestorage url to the uploaded urls
          uploadedUrls.add(downloadUrl);
        }
      }

      //Extract lat and long from the first image in the trip
      var firstImage = tripData.first;

      double? lat;
      double? long;

      if (firstImage.containsKey('latitude') &&
          firstImage.containsKey('longitude')) {
        lat = firstImage['latitude'] as double?;
        long = firstImage['longitude'] as double?;
      }

      Sight sight = Sight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Captured Image",
        description: "Sightseeing image",
        tags: ["dummy tag1", "dummy tag2"],
        lat: lat,
        long: long,
        imageUrls: uploadedUrls,
      );

      print(sight.toString());

      Sights.add(sight);
    }

    //Print the entire Sights array after adding all objects
    print("Sights Array: $Sights");

    //After creating the Sights array
    sendSights(Sights);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlaceProvider = Provider.of<SelectedPlaceProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Create your own sightseeing mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Single list for both locations and image trips
            Expanded(
              child: ListView.builder(
                itemCount: selectedPlaceProvider.selectedLocations.length,
                itemBuilder: (context, index) {
                  final item = selectedPlaceProvider.selectedLocations[index];

                  if (item is LocationInfo) {
                    // Display location item
                    final firstImageUrl =
                        item.imageUrls.isNotEmpty ? item.imageUrls[0] : null;

                    return ListTile(
                      leading: firstImageUrl != null
                          ? Image.network(
                              firstImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.location_on, color: Colors.blue),
                      title: Text(
                        item.prediction.mainText ?? "Unknown Place",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        item.prediction.secondaryText ?? "No details available",
                      ),
                    );
                  } else if (item is List<Map<String, dynamic>>) {
                    // Display image trip item
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: item.map<Widget>((imageData) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  File(imageData['photo']),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink(); // Fallback for unknown types
                  }
                },
              ),
            ),
          ],
        ),
      ),

      // Floating buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'locationButton',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: PlacesAutoCompleteField(
                      apiKey: "AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0",
                    ),
                  ),
                ),
              );
            },
            child: Icon(Icons.map),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'cameraButton',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraPage()),
              );
            },
            child: Icon(Icons.camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'saveButton',
            onPressed: () {
              onSightSave();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SsmPage()),
              );
            },
            child: Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
