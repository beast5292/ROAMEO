import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch sights by keyword search
Future<List<dynamic>> searchSights(String keyword) async {
  final response = await http.get(
    Uri.parse('http://192.168.1.5:8000/sights/search/?query=$keyword'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['sights']; // List of matched sightseeing modes
  } else {
    throw Exception('No matching sights found');
  }
}
