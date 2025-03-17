//To store and provide the sight object that's currently running
import 'package:flutter/material.dart';

class SightProvider with ChangeNotifier {

  //array to hold sights
  List<dynamic> _sights = [];

  //Getter for the sights list
  List<dynamic> get sights => _sights;

  //Method to update the sights list
  void setSights(List<dynamic> sights) {
    _sights = sights;
    notifyListeners(); //Notify listeners to rebuild widgets
  }

  //Method to get a specific sight by index
  dynamic getSight(int index) {
    if (index >= 0 && index < _sights.length) {
      return _sights[index];
    }
    return null; //Return null if the index is out of bounds
  }

  
}