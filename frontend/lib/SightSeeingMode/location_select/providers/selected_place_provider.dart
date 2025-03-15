import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'package:practice/SightSeeingMode/location_select/models/location_info.dart';

//Holding all the selected location object in an array
class SelectedPlaceProvider with ChangeNotifier {
  final List<LocationInfo> _selectedLocations = [];

  List<LocationInfo> get selectedLocations => _selectedLocations;

  //set the combined object
  void addLocationInfo(LocationInfo locationInfo) {
    locationInfo.toString();

    _selectedLocations.add(locationInfo);

    notifyListeners();
  }
}
