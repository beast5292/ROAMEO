import 'package:http/http.dart' as http;
import 'dart:convert';

//Fetch sights by keyword search
Future<List<dynamic>> searchSights(String keyword) async {
  print("Searching for sights with keyword: $keyword");
  final response = await http.get(
    // API request URL with keyword as a query parameter
    Uri.parse('http://192.168.125.74:8000/search/?query=$keyword'),
  );

  print("API Response Code: ${response.statusCode}"); //Debug
  print("API Response Body: ${response.body}"); //Debug

  if (response.statusCode == 200) {
    // Decode JSON respponse body
    final Map<String, dynamic> responseData = json.decode(response.body);
    print("Parsed Response Data: $responseData");

    // Check if response contains 'sights' key
    if (responseData.containsKey('sights')) {
      // Extract sights list from response
      List<dynamic> sights =
          responseData['sights']; // Extract list of sights from the response
      print("Sights Found: ${sights.length}");
      return sights; // Return sights list
    } else {
      throw Exception("No matching sights found in response");
    }
  } else {
    throw Exception("Failed to fetch sights: ${response.statusCode}");
  }
}
