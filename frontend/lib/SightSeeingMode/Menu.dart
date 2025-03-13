import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Services/SightsSend.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/models/sight.dart';
import 'package:practice/providers/combined_provider.dart';

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
    final combinedListProvider =
        Provider.of<CombinedListProvider>(context, listen: false);


    //list to hold the Sightseeing mode object
    List<Sight> Sights = [];


    // Iterate through the combined list and create Sight objects
    for (var item in combinedListProvider.combinedList) {
      if (item is LocationInfo) {
        Sight sight = Sight(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: item.prediction.mainText ?? "Unknown Place",
          description: item.prediction.secondaryText ?? "No details available",
          tags: ["dummyTag", "dummyTag2"],
          lat: item.placeDetails.latitude,
          long: item.placeDetails.longitude,
          imageUrls: item.imageUrls.isNotEmpty ? item.imageUrls : [],
        );

        Sights.add(sight);
      } else if (item is List<dynamic>) {
        // Handle image trips
        List<String> imagePaths = item
            .where((imageData) =>
                imageData.containsKey('photo') && imageData['photo'] != null)
            .map<String>((imageData) => imageData['photo'] as String)
            .toList();

        List<String> uploadedUrls = [];
        for (String path in imagePaths) {
          if (path.endsWith('.jpg')) {
            String downloadUrl = await uploadImage(path);
            uploadedUrls.add(downloadUrl);
          }
        }

        var firstImage = item.first;
        double? lat = firstImage['latitude'] as double?;
        double? long = firstImage['longitude'] as double?;

        Sight sight = Sight(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "Captured Image",
          description: "Sightseeing image",
          tags: ["dummy tag1", "dummy tag2"],
          lat: lat,
          long: long,
          imageUrls: uploadedUrls,
        );

        Sights.add(sight);
      }

    
    }

    //Print the entire Sights array after adding all objects
    print("Sights Array: $Sights");

    //After creating the Sights array
    sendSights(Sights);
  }

   @override
  Widget build(BuildContext context) {
    final combinedListProvider = Provider.of<CombinedListProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Create your own sightseeing mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Reorderable list view
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  // Handle reordering logic here
                  combinedListProvider.reorderItems(oldIndex, newIndex);
                },
                children: combinedListProvider.combinedList.map<Widget>((item) {
                  // Use a stable key based on the item's type and index
                  final index = combinedListProvider.combinedList.indexOf(item);
                  final key = ValueKey('${item.runtimeType}-$index');

                  if (item is LocationInfo) {
                    // Display location item
                    final firstImageUrl =
                        item.imageUrls.isNotEmpty ? item.imageUrls[0] : null;

                    return ListTile(
                      key: key,
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
                  } else if (item is  List<Map<String, dynamic>>) {
                    // Display image item
                    return ListTile(
                      key: key,
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
                    return SizedBox.shrink(); //Fallback for unknown types
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
