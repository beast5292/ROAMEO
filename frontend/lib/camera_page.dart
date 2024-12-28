import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Camera Example"),
      ),
      body: Center(
        child: _image == null
            ? const Text("No image captured")
            : Image.file(_image!),
      ),
      // Center the button inside the page
      floatingActionButton: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: _openCamera,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            iconColor: Colors.blue, // You can customize the color
          ),
          child: const Icon(Icons.camera_alt, size: 30),
        ),
      ),
    );
  }
}
