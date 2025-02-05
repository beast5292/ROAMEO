import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'package:practice/SightSeeingMode/location_select/models/placeDetailsmodal.dart';

//combined modal of place details and predictions
class LocationInfo {
  
  final PlacePrediction prediction;

  final PlaceDetails placeDetails;

  //constructor
  LocationInfo({
    required this.prediction,
    required this.placeDetails,
  });

}
