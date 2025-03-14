import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> _searchLocations(String keyword) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/search_sights/?name=$keyword'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']); // Convert to list
  } else {
    throw Exception('Failed to load search results');
  }
}
