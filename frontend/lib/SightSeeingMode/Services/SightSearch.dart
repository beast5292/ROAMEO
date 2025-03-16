import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Function to send search query to FastAPI and retrieve results
Future<List<Map<String, dynamic>>> searchLocations(String keyword) async {
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
