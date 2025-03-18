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
      imageUrl: "https://picsum.photos/id/15/367/267", // Example image URL
      name: "Nine Arch Bridge",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non quam nulla. Fusce est felis, tempus porttitor mi ut, finibus sagittis lorem. Nullam a pulvinar velit. Vivamus sed ex dolor. Ut consequat vestibulum est vel egestas. Maecenas eu augue eu risus placerat feugiat vitae in diam. Vestibulum pulvinar vestibulum ornare. Vivamus eu condimentum sapien. Duis diam ex, luctus nec tincidunt vel, fringilla vitae ligula. Mauris at tortor consequat, ornare sapien at, blandit orci.",
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