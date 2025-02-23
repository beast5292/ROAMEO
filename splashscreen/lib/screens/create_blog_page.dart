import 'package:flutter/material.dart';
import 'dart:io';
import '../models/blog_model.dart';
import 'package:image_picker/image_picker.dart';

class CreateBlogPage extends StatefulWidget {
  final Function(Blog) onSubmit; // Add the onSubmit callback

  const CreateBlogPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Blog",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        actions: [ // Use actions for the right corner
          TextButton( // Or IconButton if you want an icon
              onPressed: () {
                final newBlog = Blog(
                  title: _titleController.text,
                  content: _contentController.text,
                  //image: _image,
                );
                widget.onSubmit(newBlog);
                Navigator.pop(context);
              },
              child: Container(
                child: const Text("Post", style: TextStyle(color: Colors.white, fontSize: 17)),

              )

            // text inside a box if needed
            /*child: Container(
          decoration: BoxDecoration(
          color: Colors.grey, // Background color of the box
            borderRadius: BorderRadius.circular(10.0), // Adjust the radius for curvature
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding inside the box
          child: const Text("Post", style: TextStyle(color: Colors.white)),
          )*/

          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold), // Hint text color
                enabledBorder: UnderlineInputBorder( // Underline color when enabled
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder( // Underline color when focused
                  borderSide: BorderSide(color: Colors.white70), // Example: Blue when focused
                ),
              ),
              style: const TextStyle(color: Colors.white), // Text color
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white,fontSize: 20), // Hint text color
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70), // Example: Blue when focused
                ),
              ),
              maxLines: 4,
              style: const TextStyle(color: Colors.white), // Text color
            ),

            SizedBox(height: 50,),
            Row(
              children: [
                if (_image != null) Image.file(_image!),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo, color: Colors.white, size: 30,),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.poll_outlined, color: Colors.white, size: 31,),
                ),
              ],
            )


          ],
        ),
      ),
    );
  }
}

