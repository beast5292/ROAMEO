import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'registration_complete_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SetupAccountPage extends StatefulWidget {
  const SetupAccountPage({super.key});

  @override
  _SetupAccountPageState createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  /// Load user email from secure storage
  Future<void> _loadUserEmail() async {
    final String? email = await _secureStorage.read(key: 'user_email');
    print("Stored user email: $email"); // Debugging log
    setState(() {
      userEmail = email;
    });

    if (email == null) {
      _showSnackBar('User email not found. Please log in again.');
    }
  }

  /// Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Upload image to Firebase Storage and update Firestore
  Future<void> _uploadImage() async {
    if (_image == null) {
      _showSnackBar('Please select an image');
      return;
    }
    if (userEmail == null) {
      _showSnackBar('Error: User email not found. Please log in again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String fileName = 'profile_$userEmail.jpg';
      final Reference storageRef =
          _storage.ref().child('profile_images/$fileName');
      await storageRef.putFile(_image!);
      final String downloadURL = await storageRef.getDownloadURL();

      DocumentReference userDoc = _firestore.collection('users').doc(userEmail);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({'profileImage': downloadURL});
      } else {
        await userDoc.set({'profileImage': downloadURL});
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegistrationCompletePage()),
      );
    } catch (e) {
      print("Error uploading image: $e");
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 35,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Setup your\n account",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(68, 202, 233, 1),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Finish your account setup by\n uploading your profile picture.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : const AssetImage('assets/profile_placeholder.png')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 32, 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
