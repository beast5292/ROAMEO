import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class CreateBlogPage extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  const CreateBlogPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Blog', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          // Submit button in the top-right corner
          TextButton(
            onPressed: () async {
              print("Submit button pressed");

              final blog = {
                "title": _titleController.text,
                "content": _contentController.text,
                "imagePath": _selectedImage?.path ?? "",
                "userName": "Current User",
                "userProfileImage": "default_image_url",
                "timestamp": DateTime.now().toIso8601String(),
              };

              print("Blog data: $blog");

              try {
                print("Calling API to create blog...");
                await ApiService.createBlog(blog);
                print("Blog created successfully");

                widget.onSubmit(blog);

                Navigator.pop(context);  // Close the CreateBlogPage
              } catch (e) {
                print("Error creating blog: $e");
              }
            },
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 250, // You can adjust the height as needed
                width: double.infinity, // Ensures the image stretches to fit the width
                fit: BoxFit.contain, // This makes sure the entire image is visible without cropping
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
