import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:practice/SightSeeingMode/Simulation/services/alertDialog.dart';

//fetch all the sightseeing modes
Future<List<dynamic>> fetchSights() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/sights/'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['sights']; // List of sightseeing modes
  } else {
    throw Exception('Failed to load sights');
  }
}

//fetch sightseeing modes by docId
Future<Map<String, dynamic>> fetchSightMode(String docId) async {
  final response =
      await http.get(Uri.parse('http://10.0.2.2:8000/sights/$docId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print("Recieved sight mode - ");
    print(data);
    return data; //Returns the entire sight data including "id" and "sights"
  } else {
    throw Exception('Failed to load sight mode');
  }
}


//fetch all the sights of sightseeing modes

