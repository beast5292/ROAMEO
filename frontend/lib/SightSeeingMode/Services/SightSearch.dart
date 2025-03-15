import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Future<List<Map<String, dynamic>>> _searchLocations(String keyword) async {
//   final encodedKeyword = Uri.encodeComponent(keyword); // Encode the keyword
//   final response = await http.get(
//     Uri.parse('http://10.0.2.2:8000/search_sights/?name=$encodedKeyword'),
//     headers: {
//       HttpHeaders.contentTypeHeader: 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     return List<Map<String, dynamic>>.from(data['results']); // Convert to list
//   } else {
//     throw Exception('Failed to load search results');
//   }
// }

Future<List<Map<String, dynamic>>> _searchLocations(String keyword) async {
  final encodedKeyword = Uri.encodeComponent(keyword); // Encode the keyword

  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/search_sights/?name=$encodedKeyword'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data['results']); // Convert to list
    } else {
      throw Exception('Failed to load search results');
    }
  } catch (e) {
    debugPrint("Network request failed: $e");
    return [];
  }
}

// Method to handle search button press
void _performSearch() async {
  String searchQuery = _searchController.text.trim();

  if (searchQuery.isNotEmpty) {
    try {
      List<Map<String, dynamic>> results = await _searchLocations(searchQuery);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint("Error fetching search results: $e");
    }
  }
}
