import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';

class CombinedListProvider with ChangeNotifier {

  final SelectedPlaceProvider selectedPlaceProvider;
  final SelectedImageProvider selectedImageProvider;

  CombinedListProvider(this.selectedPlaceProvider, this.selectedImageProvider);

  List<dynamic> get combinedList => [
        ...selectedPlaceProvider.selectedLocations,
        ...selectedImageProvider.selectedTrips,
      ];
  
   void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= combinedList.length) return;
    if (newIndex < 0 || newIndex >= combinedList.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Get the item being moved
    final item = combinedList[oldIndex];

    // Remove the item from its current position
    if (item is LocationInfo) {
      // Find the correct index in selectedPlaceProvider.selectedLocations
      final locationIndex = selectedPlaceProvider.selectedLocations.indexOf(item);
      if (locationIndex != -1) {
        selectedPlaceProvider.selectedLocations.removeAt(locationIndex);
      }
    } else if (item is List<Map<String, dynamic>>) {
      // Find the correct index in selectedImageProvider.selectedTrips
      final imageTripIndex = selectedImageProvider.selectedTrips.indexOf(item);
      if (imageTripIndex != -1) {
        selectedImageProvider.selectedTrips.removeAt(imageTripIndex);
      }
    }

    // Insert the item at the new position
    if (item is LocationInfo) {
      // Calculate the correct index for selectedPlaceProvider.selectedLocations
      final locationIndex = newIndex.clamp(0, selectedPlaceProvider.selectedLocations.length);
      selectedPlaceProvider.selectedLocations.insert(locationIndex, item);
    } else if (item is List<Map<String, dynamic>>) {
      // Calculate the correct index for selectedImageProvider.selectedTrips
      final imageTripIndex = newIndex.clamp(0, selectedImageProvider.selectedTrips.length);
      selectedImageProvider.selectedTrips.insert(imageTripIndex, item);
    }

    // Notify listeners to update the UI
    notifyListeners();
  }
  // Notify listeners to update the UI
  notifyListeners();
}


