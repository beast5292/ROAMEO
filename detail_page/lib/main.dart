import 'package:flutter/material.dart';
import 'detail_page.dart'; // Import the DetailPage
import 'location_model.dart'; // Import the Location model

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the location data
    final location = Location(
      imageUrl: "https://picsum.photos/500/300", // Example image URL
      name: "Nine Arch Bridge",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
      rating: 4.5,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetailPage(
        location: location, // Pass the location data to the DetailPage
      ),
    );
  }
}