import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/Services/SightsSend.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Ella_test.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/models/sight.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:ui';

class SightMenu extends StatefulWidget {
  const SightMenu({super.key});

  @override
  State<SightMenu> createState() => _SightMenuState();
}

class _SightMenuState extends State<SightMenu> {
  Future<String> uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = filePath.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
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
          title: Text("Edit $title", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1A1A1A),
          content: TextField(
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $title",
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                String enteredText = _controller.text;
                Provider.of<SelectedPlaceProvider>(context, listen: false)
                    .editItemByIndex(index, enteredText, title);
                Navigator.pop(context, enteredText);
              },
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
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
          title: const Text("Save Sight Mode", 
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1A1A1A),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Mode Name",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),         
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSightSave(_nameController.text, _descriptionController.text);
              },
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> onSightSave(String sightModeName, String sightDescription) async {
    final selectedPlaceProvider =
        Provider.of<SelectedPlaceProvider>(context, listen: false);
    final selectedImageProvider =
        Provider.of<SelectedImageProvider>(context, listen: false);

    List<Sight> sights = [];

    for (var location in selectedPlaceProvider.selectedLocations) {
      if (location is LocationInfo) {
        Sight sight = Sight(
          modeName: sightModeName,
          modeDescription: sightDescription,
          username: "ROAMEO",
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: location.name,
          description: location.description,
          tags: location.tags,
          lat: location.placeDetails.latitude,
          long: location.placeDetails.longitude,
          imageUrls: location.imageUrls.isNotEmpty ? location.imageUrls : [],
        );
        sights.add(sight);
      }

      if (location is List<Map<String, dynamic>>) {
        List<String> imagePaths = location
            .where((imageData) => imageData.containsKey('photo'))
            .map<String>((imageData) => imageData['photo'] as String)
            .toList();

        List<String> uploadedUrls = [];
        for (String path in imagePaths) {
          if (path.endsWith('.jpg')) {
            String downloadUrl = await uploadImage(path);
            uploadedUrls.add(downloadUrl);
          }
        }

        var firstImage = location.first;
        sights.add(Sight(
          modeName: sightModeName,
          modeDescription: sightDescription,
          username: "ROAMEO",
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: firstImage['name'],
          description: firstImage['description'],
          tags: firstImage['tags'],
          lat: firstImage['latitude'],
          long: firstImage['longitude'],
          imageUrls: uploadedUrls,
        ));
      }
    }

    sendSights(sights);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlaceProvider = Provider.of<SelectedPlaceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF030A0E),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Positioned(
  top: MediaQuery.of(context).padding.top + 15,
  left: 20,
  child: FloatingActionButton.small(
    backgroundColor: Colors.black.withOpacity(0.3),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.white.withOpacity(0.2)),
    ), // Added missing parenthesis here
    onPressed: () => Navigator.pop(context),
    child: Icon(
      Icons.arrow_back_rounded,
      color: Colors.white,
      size: 30,
    ),
  ),
),

              const SizedBox(
                width: double.infinity,
              ),
              const SizedBox(height: 15),
              Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  selectedPlaceProvider.reorderTrips(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Color(0xFF1E1E1E).withOpacity(0.9),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 10,

                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                children: selectedPlaceProvider.selectedLocations
                    .asMap()
                    .entries
                    .map<Widget>((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final key = ValueKey(item.hashCode);

                  return Container(
                    key: key,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFF1E1E1E).withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: _buildListItem(item, index),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFloatingButton(
            icon: Icons.map,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: PlacesAutoCompleteField(
                    apiKey: "AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0",
                  ),
                ),
              ),
            ),
          ),
          _buildFloatingButton(
            icon: Icons.camera_alt,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()),),
          ),
          _buildFloatingButton(
            icon: Icons.save,
            onPressed: () => _showSaveDialog(context),
          ),
          _buildFloatingButton(
            icon: Icons.train,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                icon: Icon(icon, size: 28),
                color: Colors.white,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(dynamic item, int index) {
    if (item is LocationInfo) {
      return ListTile(
        contentPadding: const EdgeInsets.all(16),
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
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                  onPressed: () => _showEditDialog(context, "Name", index),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                  onPressed: () => _deleteItem(item),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.description ?? "No description available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
            ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: item.tags.map((tag) => _buildTag(tag)).toList(),
            ),
          ],
        ),
      );
    } else if (item is List<Map<String, dynamic>>) {
      final firstItem = item.isNotEmpty ? item.first : null;
      return ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: firstItem != null && firstItem.containsKey('photo')
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
            Text(
              firstItem?['name'] ?? 'Image Collection',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${item.length} images",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
            ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
              onPressed: () => _showEditDialog(context, "Name", index),
            ),
            IconButton(
              icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
              onPressed: () => _deleteItem(item),
            ),
          ],
        ),
      );
    }
    return const ListTile(
        title: Text("Unknown item", style: TextStyle(color: Colors.white)));
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[100]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          color: Colors.blue[200],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
