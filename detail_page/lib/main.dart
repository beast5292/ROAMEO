import 'package:flutter/material.dart';
import 'detail_page.dart'; // Import the DetailPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetailPage(), // Set DetailPage as the home screen
    );
  }
}