import 'package:http/http.dart' as http;
import 'dart:convert';

//fetch all the sights
Future<List<dynamic>> fetchSights() async {
  
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/sights/'));
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['sights'];  // List of sightseeing modes
  } else {
    throw Exception('Failed to load sights');
  }
}

//fetch sight by index
Future<Map<String,dynamic>> fetchSightMode(int index) async {
  
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/sights/$index'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['sights'][index];  //get the specific sight
  } else {
    throw Exception('Failed to load sight mode');
  }
}

