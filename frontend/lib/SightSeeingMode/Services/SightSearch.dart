import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch sights by keyword search
Future<List<dynamic>> searchSights(String keyword) async {
  final response = await http.get(
    Uri.parse('http://10.31.10.32:8000/search/?query=$keyword'),
  );

  print("API Response Code: ${response.statusCode}");
  print("API Response Body: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    print("Parsed Response Data: $responseData");

    if (responseData.containsKey('sights')) {
      List<dynamic> sights = responseData['sights'];
      print("Sights Found: ${sights.length}");
      return sights;
    } else {
      throw Exception("No matching sights found in response");
    }
  } else {
    throw Exception("Failed to fetch sights: ${response.statusCode}");
  }

  //   final data = json.decode(response.body);
  //   return data['sights']; // List of matched sightseeing modes
  // } else {
  //   throw Exception('No matching sights found');
  // }
}
