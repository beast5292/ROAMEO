import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';

//Holding all the selected location object in an array
class SelectedPlaceProvider with ChangeNotifier {

  List<dynamic> _selectedLocations = [];

  List<dynamic> get selectedLocations => _selectedLocations;

  //set the combined location object and add it to the array
  void addLocationInfo(LocationInfo locationInfo) {
    locationInfo.toString();

    _selectedLocations.add(locationInfo);

    notifyListeners();
  }

  //set the combined image object and add it to the array
  void addImageInfo(List<Map<String, dynamic>> tripData) {
    
    print(tripData);

    _selectedLocations.add(tripData);

    notifyListeners();
  }
}
