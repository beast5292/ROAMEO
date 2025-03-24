import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/location_select/models/autoCmodal.dart';
import 'dart:convert';


class PlaceAutoCompleteService {

  final String apiKey;

  final String baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  PlaceAutoCompleteService({required this.apiKey});

  Future<List<PlacePrediction>> getPlacePrediction({
    required String input,
    String? sessionToken,
    String? language,
    String? components,
    double? latitude,
    double? longitude,
    int? radius,
    String? types,
    bool? strictbounds,
  }) async {
    try {
      //Assigning the parameter object to send a request to the api
      //required params an optional params included
      final params = {
        'input': input,
        'key': apiKey,
        'components': 'country:lk',
        if (sessionToken != null) 'sessiontoken': sessionToken,
        if (language != null) 'language': language,
        if (components != null) 'components': components,
        if (latitude != null && longitude != null)
          'location': '$latitude,$longitude',
        if (radius != null) 'radius': radius.toString(),
        if (types != null) 'types': types,
        if (strictbounds != null) 'strictbounds': strictbounds.toString(),
      };

      //replace the uri string with params as queryParameters
      final uri = Uri.parse(baseUrl).replace(queryParameters: params);

      //send a get request to the uri
      final response = await http.get(uri);

      //if the statusCode is 200
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == "OK") {
          return (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
        } else {
          throw Exception(
              data['error_message'] ?? 'Places API error ${data['status']}');
        }
      } else {
        throw Exception("Failed to fetch predictions");
      }
    } catch (e) {
      throw Exception("Error fetching place predictions: $e");
    }
  }
}
