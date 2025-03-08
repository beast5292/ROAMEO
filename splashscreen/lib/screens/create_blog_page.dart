import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/blog_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBlogPage extends StatefulWidget {
  final Function(Blog) onSubmit; // Add this line to accept the callback

  const CreateBlogPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}


class _CreateBlogPageState extends State<CreateBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = 'blog_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _submitBlog() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title and content cannot be empty")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    String postId = FirebaseFirestore.instance.collection('posts').doc().id;

    void _submitBlog() async {
      Blog newBlog = Blog(
        id: FirebaseFirestore.instance.collection('posts').doc().id, // Generate an ID for the new post
        title: _titleController.text,
        content: _contentController.text,
        userName: 'User Name', // Update to current user
        userProfileImage: 'lib/assets/images/cars5.png',
        timestamp: Timestamp.now(),
        imagePath: null, // Handle image uploading if applicable
      );

      try {
        await FirebaseFirestore.instance.collection('posts').doc(newBlog.id).set({
          'title': newBlog.title,
          'content': newBlog.content,
          'userName': newBlog.userName,
          'userProfileImage': newBlog.userProfileImage,
          'timestamp': newBlog.timestamp,
          'likes': 0, // Initialize like count
          'dislikes': 0, // Initialize dislike count
          'imagePath': newBlog.imagePath, // Handle the image if applicable
        });

        widget.onSubmit(newBlog); // Notify parent widget of new blog
        Navigator.pop(context); // Close the page
      } catch (e) {
        // Handle errors here
        print('Error adding blog: $e');
      }
    }


    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Blog", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          _isLoading
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CircularProgressIndicator(color: Colors.white),
          )
              : TextButton(
            onPressed: _submitBlog,
            child: Text("Post", style: TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _contentController, decoration: InputDecoration(labelText: 'Content'), maxLines: 4),
            IconButton(onPressed: _pickImage, icon: Icon(Icons.add_a_photo)),
          ],
        ),
      ),
    );
  }
}
