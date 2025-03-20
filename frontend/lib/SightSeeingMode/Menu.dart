import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Services/SightsSend.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Ella_test.dart';
import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';
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
  
  //api key
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];


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

  void _deleteItem(dynamic item) {
    final selectedPlaceProvider =
        Provider.of<SelectedPlaceProvider>(context, listen: false);
    selectedPlaceProvider.removeItem(item);
  }

  void _showEditDialog(BuildContext context, String title, int index) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter new $title",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String enteredText = _controller.text;

                Provider.of<SelectedPlaceProvider>(context, listen: false)
                    .editItemByIndex(index, enteredText, title,context);
                Navigator.pop(context, enteredText);
               
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Sight Mode"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Sight Mode Name"),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Sight Mode Name",
                ),
              ),
              const SizedBox(height: 10),
              const Text("Enter Description"),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String sightModeName = _nameController.text;
                String description = _descriptionController.text;
                print('Sight Mode Name: $sightModeName');
                print('Description: $description');
                Navigator.pop(context);
                onSightSave(_nameController.text, _descriptionController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  onSightSave(String sightModeName, String sightDescription) async {
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
          modeName: sightModeName,
          modeDescription: sightDescription,
          username: "ROAMEO",
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Unique ID from the place API
          name: location.name,
          description: location.description,
          tags: location.tags, // You can modify this to add tags if needed
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

        //Extract name from the first image in the trip
        String? name;

        if (firstImage.containsKey('name')) {
          name = firstImage['name'] as String?;
        }

        //Extract tags from the first image in the trip
        List<String>? tags;

        if (firstImage.containsKey('tags')) {
          tags = firstImage['tags'] as List<String>?;
        }

        //Extract description from the first image in the trip
        String? description;

        if (firstImage.containsKey('description')) {
          description = firstImage['description'] as String?;
        }

        Sight sight = Sight(
          modeName: sightModeName,
          modeDescription: sightDescription,
          username: "ROAMEO",
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          tags: tags,
          lat: lat,
          long: long,
          imageUrls: uploadedUrls,
        );

        print(sight.toString());

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
                  selectedPlaceProvider.reorderTrips(oldIndex, newIndex);
                },
                children: selectedPlaceProvider.selectedLocations
                    .asMap() // Convert the list to a map of index-value pairs
                    .entries
                    .map<Widget>((entry) {
                  final index = entry.key; // Get the index
                  final item = entry.value; // Get the item
                  final key =
                      ValueKey(item.hashCode); // Unique key for each item

                  if (item is LocationInfo) {
                    return ListTile(
                      key: key,
                      contentPadding: const EdgeInsets.all(8.0),
                      leading: item.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrls.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  _showEditDialog(
                                      context, "Name", index); // Pass the index
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _deleteItem(item);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.description ??
                                      "No details available",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  _showEditDialog(context, "Description",
                                      index); // Pass the index
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                children: item.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  _showEditDialog(context, "Tag", index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add,
                                          size: 16, color: Colors.black),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add Tag',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (item is List<Map<String, dynamic>>) {
                    // Handle List<Map<String, dynamic>> type
                    final firstItem = item.isNotEmpty ? item.first : null;

                    if (firstItem != null) {
                      return ListTile(
                        key: key,
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: firstItem.containsKey('photo') &&
                                firstItem['photo'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(firstItem['photo']),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    firstItem['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () {
                                    _showEditDialog(context, "Name",
                                        index); // Pass the index
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    firstItem['description'] ??
                                        'No details available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () {
                                    _showEditDialog(context, "Description",
                                        index); // Pass the index
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _deleteItem(item);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (firstItem.containsKey('tags') &&
                                firstItem['tags'] is List)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    children: (firstItem['tags'] as List)
                                        .map<Widget>((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(context, "Tag", index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add,
                                              size: 16, color: Colors.black),
                                          SizedBox(width: 4),
                                          Text(
                                            'Add Tag',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                  }
                  return Container(); // Fallback for unexpected types
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
                      apiKey: apiKey,
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
              _showSaveDialog(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SsmPage()),
              // );
            },
            child: Icon(Icons.save),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'saveButton',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
            child: Icon(Icons.train),
          ),
        ],
      ),
    );
  }
}
