import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/models/sight.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Make sure to import dart:io for File handling

class SightMenu extends StatefulWidget {
  const SightMenu({super.key});

  @override
  State<SightMenu> createState() => _SightMenuState();
}

class _SightMenuState extends State<SightMenu> {
  bool showLocations = true; // Toggle switch state

  onSightSave() {
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

      sight.toString();

      Sights.add(sight);
    }

    //iterate through selected images and create Sight objects
    for (var tripData in selectedImageProvider.selectedTrips) {
      if (tripData.isNotEmpty) {
        List<String> imagePaths =
            tripData.map<String>((imageData) => imageData['photo']).toList();

        //Accessing lat and long from first image
        double? lat = tripData.first['location']?.latitude;
        double? long = tripData.first['location']?.longitude;

        Sight sight = Sight(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Generate a unique ID
          name: "Captured Image",
          description: "Sightseeing image",
          tags: ["dummy tag1", "dummy tag2"],
          lat: lat,
          long: long,
          imageUrls: imagePaths,
        );

        sight.toString();

        Sights.add(sight);
      }
    }

    // Print the entire Sights list for debugging
    print("Sights Array: ${Sights.map((sight) => sight.toString()).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlaceProvider = Provider.of<SelectedPlaceProvider>(context);
    final selectedImageProvider = Provider.of<SelectedImageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("Create your own sightseeing mode",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Locations", style: TextStyle(fontSize: 16)),
                Switch(
                  value: showLocations,
                  onChanged: (value) {
                    setState(() {
                      showLocations = value;
                    });
                  },
                ),
                Text("Images", style: TextStyle(fontSize: 16)),
              ],
            ),

            Expanded(
              child: showLocations
                  ? ListView.builder(
                      itemCount: selectedPlaceProvider.selectedLocations.length,
                      itemBuilder: (context, index) {
                        final location =
                            selectedPlaceProvider.selectedLocations[index];

                        // Get the first image URL from the Images list
                        final firstImageUrl = location.imageUrls.isNotEmpty
                            ? location.imageUrls[0]
                            : null;

                        return ListTile(
                          leading: firstImageUrl != null
                              ? Image.network(firstImageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover) // Smaller image size
                              : Icon(Icons.location_on,
                                  color: Colors
                                      .blue), // Fallback icon if no image is available
                          title: Text(
                              location.prediction.mainText ?? "Unknown Place",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(location.prediction.secondaryText ??
                              "No details available"),
                        );
                      },
                    )
                  : selectedImageProvider.selectedTrips.isEmpty
                      ? Center(
                          child: Text("No images added yet",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)))
                      : ListView.builder(
                          itemCount: selectedImageProvider.selectedTrips.length,
                          itemBuilder: (context, index) {
                            final tripData =
                                selectedImageProvider.selectedTrips[index];

                            if (tripData.isEmpty) {
                              return SizedBox.shrink();
                            }

                            final imageDataList = tripData;

                            return ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children:
                                        imageDataList.map<Widget>((imageData) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.file(
                                          File(imageData['photo']),
                                          width: 150, // Smaller image size
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
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
