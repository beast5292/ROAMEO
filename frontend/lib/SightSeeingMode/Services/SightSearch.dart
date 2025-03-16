import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Function to send search query to FastAPI and retrieve results
Future<List<Map<String, dynamic>>> searchLocations(String keyword) async {
  final encodedKeyword = Uri.encodeComponent(keyword); // Encode the keyword
  debugPrint("Sending request to Fast API with Keyword: $encodedKeyword");

  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.5:8000/search_sights/?name=$encodedKeyword'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    debugPrint(
        "Received response with status: ${response.statusCode}"); //  Debug
    debugPrint("Response body: ${response.body}"); //  Debug

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint("Parsed data: $data"); //  Debug
      return List<Map<String, dynamic>>.from(
          data['results']); // Convert to list
    } else {
      throw Exception('Failed to load search results');
    }
  } catch (e) {
    debugPrint("Network request failed: $e"); //  Debug
    return [];
  }
}
