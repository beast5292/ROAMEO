import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/location_select/models/placeDetailsmodal.dart';

class Placedetailservice {
  final String apiKey;

  //base url to access the places api
  final String baseUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  Placedetailservice({required this.apiKey});

  //returning a place Details object
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    //constructing the url with the place id to be sent
    final url = '$baseUrl?place_id=$placeId&key=$apiKey';

    //sending a get request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == "OK") {
        //return a place details object
        return PlaceDetails.fromJson(data);
      } else {
        throw Exception("Failed to fetch the place details");
      }
    } else {
      throw Exception("Failed to fetch the place details");
    }
  }
}
