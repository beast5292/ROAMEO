import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Simulation/services/Haversine_formula.dart';

bool isLocationWithinPolylineThreshold(LatLng currentLocation,
    List<LatLng> polylineCoordinates, double threshold) {
  for (var point in polylineCoordinates) {
    double distance = calculateDistance(currentLocation, point);
    if (distance <= threshold) {
      return true;
    }
  }
  return false;
}
