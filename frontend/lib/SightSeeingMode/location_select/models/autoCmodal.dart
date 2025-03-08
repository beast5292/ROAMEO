class PlacePrediction {
  
  //instance variables to hold the output
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;


  //Assigning a place prediction object containing the output values
  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  //factory constructor to convert the json response to an object and return a placeprediction object
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: json['structured_formatting']['main_text'] as String,
      secondaryText: json['structured_formatting']['secondary_text'] as String,
      types: (json['types'] as List).map((type) => type as String).toList(),
    );
  }
}

  //Modal is to hold the output data and convert it into an object

  //Json reponse we are converting
//   {
//   "predictions": [
//     {
//       "description": "Paris, France",
//       "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
//       "structured_formatting": {
//         "main_text": "Paris",
//         "secondary_text": "France"
//       },
//       "types": ["locality", "political", "geocode"]
//     }
//   ],
//   "status": "OK"
// }
