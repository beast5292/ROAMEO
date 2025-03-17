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
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:ui'; // Added for blur effect

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
      backgroundColor: const Color(0xFF030A0E),
      appBar: AppBar(
        title: const Text('Sightseeing Menu', 
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  SizedBox(
    width: double.infinity, // Force full width
    child: const Text(
      "Create your own sightseeing mode",
      textAlign: TextAlign.center, // Center text within container
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    ),
  ),
  const SizedBox(height: 20),
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

                    return Container(
                      key: key,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: _buildListItem(item),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating buttons
     floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    // Map Button
    Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ClipRRect(
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
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.map, size: 28),
                color: Colors.white,
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
              ),
            ),
          ),
        ),
      ),
    ),
    // Camera Button
    Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ClipRRect(
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
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 28),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
    // Save Button
    Align(
      alignment: Alignment.bottomRight,
      child: ClipRRect(
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
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.save, size: 28),
              color: Colors.white,
              onPressed: () {
                onSightSave();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SsmPage()),
                );
              },
            ),
          ),
        ),
      ),
    ),
  ],
),
    );
  }

  Widget _buildListItem(dynamic item) {
    if (item is LocationInfo) {
      return ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(item.prediction.mainText ?? "Unknown Place",
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(item.prediction.secondaryText ?? "No details available",
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        trailing: const Icon(Icons.drag_handle, color: Colors.white54),
        onTap: () {},
      );
    } else if (item is List<Map<String, dynamic>>) {
      return ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: const Text("Image Collection",
            style: TextStyle(color: Colors.white)),
        subtitle: Text("${item.length} images",
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        trailing: const Icon(Icons.drag_handle, color: Colors.white54),
        onTap: () {},
      );
    }
    return const ListTile(
      title: Text("Unknown item type", style: TextStyle(color: Colors.white)),
    );
  }
}