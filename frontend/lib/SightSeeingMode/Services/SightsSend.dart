import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:practice/SightSeeingMode/models/sight.dart';

//function to send sights to the backend
Future<void> sendSights(List<Sight> sights) async {
  final url = Uri.parse('http://10.0.2.2:8000/sights/');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode(sights
      .map((sight) => {
            'modeName': sight.modeName,
            'modeDescription': sight.modeDescription,
            'username': sight.username,
            'id': sight.id,
            'name': sight.name,
            'description': sight.description,
            'tags': sight.tags,
            'lat': sight.lat,
            'long': sight.long,
            'imageUrls': sight.imageUrls,
          })
      .toList());

  //receving response
  final response = await http.post(url, headers: headers, body: body);

  //status codes
  if (response.statusCode == 200) {
    print('Sights sent successfully!');
  } else {
    print('Failed to send sights. Status Code: ${response.statusCode}');
  }
}
