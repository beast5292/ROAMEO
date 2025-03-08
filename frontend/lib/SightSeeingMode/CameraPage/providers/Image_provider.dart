import 'package:flutter/material.dart';

//Provider for selected images
class SelectedImageProvider with ChangeNotifier {
  
  //Selected Trips array to hold an array of temp image objects
  List<List<Map<String, dynamic>>> _selectedTrips = [];
  
  //getter for selected trips
  List<List<Map<String, dynamic>>> get selectedTrips => _selectedTrips;
  
  //add Trip method to add a temp images array as tripData to the array
  void addTrip(List<Map<String, dynamic>> tripData) {

     print(tripData);
    _selectedTrips.add(tripData);
    notifyListeners();
  }
  
  //removing a trip from the selected trips array
  void removeTrip(int index) {
    _selectedTrips.removeAt(index);
    notifyListeners();
  }
}
