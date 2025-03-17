import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allows panning
          boundaryMargin: EdgeInsets.all(80), // Adjust the margins to allow zooming
          minScale: 0.1, // Minimum zoom level
          maxScale: 4.0, // Maximum zoom level
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain, // Ensures the image fits within the screen
          ),
        ),
      ),
    );
  }
}
