import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'package:practice/SightSeeingMode/location_select/models/placeDetailsmodal.dart';

//combined modal of place details and predictions
class LocationInfo {
  final PlacePrediction prediction;

  final PlaceDetails placeDetails;

  final List<String> imageUrls;

  //constructor
  LocationInfo({
    required this.prediction,
    required this.placeDetails,
    required this.imageUrls,
  });

  // Method to fetch image URLs from photo references
  static List<String> getImageUrlsFromPhotos(List<String> photos, String apiKey) {
    return photos.map((photoReference) {
      return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
    }).toList();
  }

  // Override the toString method to customize the print format
  @override
  String toString() {
    return 'Location Info: {'
        'Prediction: ${prediction.mainText}, '
        'Address: ${placeDetails.address}, '
        'Latitude: ${placeDetails.latitude}, '
        'Longitude: ${placeDetails.longitude},'
        'Description: ${prediction.description},'
        'Images: ${placeDetails.images},'
        'Images: ${imageUrls.join(', ')}'

        '}';
  }
}
