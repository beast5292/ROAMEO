import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Services/SightsSend.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/models/sight.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
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
      if (location is LocationInfo) {
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

      if (location is List<Map<String, dynamic>>) {
        //Extracting image URLs
        List<String> imagePaths = location
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
        var firstImage = location.first;

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
    }

    // for (var tripData in selectedImageProvider.selectedTrips) {
    //   //Extracting image URLs
    //   List<String> imagePaths = tripData
    //       .where((imageData) =>
    //           imageData.containsKey('photo') && imageData['photo'] != null)
    //       .map<String>((imageData) => imageData['photo'] as String)
    //       .toList();

    //   //store the uploaded Urls (jpgs uploaded to the firestorage and google map links)
    //   List<String> uploadedUrls = [];
    //   for (String path in imagePaths) {
    //     if (path.endsWith('.jpg')) {
    //       //upload the image to firestorage
    //       String downloadUrl = await uploadImage(path);

    //       //add the firestorage url to the uploaded urls
    //       uploadedUrls.add(downloadUrl);
    //     }
    //   }

    //   //Extract lat and long from the first image in the trip
    //   var firstImage = tripData.first;

    //   double? lat;
    //   double? long;

    //   if (firstImage.containsKey('latitude') &&
    //       firstImage.containsKey('longitude')) {
    //     lat = firstImage['latitude'] as double?;
    //     long = firstImage['longitude'] as double?;
    //   }

    //   Sight sight = Sight(
    //     id: DateTime.now().millisecondsSinceEpoch.toString(),
    //     name: "Captured Image",
    //     description: "Sightseeing image",
    //     tags: ["dummy tag1", "dummy tag2"],
    //     lat: lat,
    //     long: long,
    //     imageUrls: uploadedUrls,
    //   );

    //   print(sight.toString());

    //   Sights.add(sight);
    // }

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

            // Reorderable list for image trips
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  // Handle reordering logic here
                  selectedPlaceProvider.reorderTrips(oldIndex, newIndex);
                },
                children: selectedPlaceProvider.selectedLocations
                    .map<Widget>((dynamic item) {
                  final key =
                      ValueKey(item.hashCode); // Unique key for each item

                  if (item is LocationInfo) {
                    // Handle LocationInfo type
                    return ListTile(
                      key: key,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.prediction.mainText ?? "Unknown Place"),
                          Text(item.prediction.secondaryText ??
                              "No details available"),
                          if (item.imageUrls.isNotEmpty)
                            Row(
                              children: item.imageUrls.map<Widget>((imageUrl) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    imageUrl,
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
                  } else if (item is List<Map<String, dynamic>>) {
                    // Handle List<Map<String, dynamic>> type
                    return ListTile(
                      key: key,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: item.map<Widget>((imageData) {
                              if (imageData.containsKey('photo') &&
                                  imageData['photo'] != null) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    File(imageData['photo']),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return Container(); // Handle missing photo data
                              }
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Handle unexpected types (optional)
                    return ListTile(
                      key: key,
                      title: Text("Unknown item type"),
                    );
                  }
                }).toList(),
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
