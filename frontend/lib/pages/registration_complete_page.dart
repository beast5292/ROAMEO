import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationCompletePage extends StatefulWidget {
  @override
  _RegistrationCompletePageState createState() =>
      _RegistrationCompletePageState();
}

class _RegistrationCompletePageState extends State<RegistrationCompletePage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _username; // To store the fetched username
  String? _profileImageUrl; // To store the fetched profile image URL
  bool _isLoading = true; // To show a loading indicator
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetching user data when the page loads
    fetchUserData();
  }

  // Function to fetch user data from the backend and Firestore
  Future<void> fetchUserData() async {
    try {
      final String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('http://10.0.2.2:8000/user');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final userEmail = responseBody["user"]["email"]; // Get user email

        // Fetching profile image URL from Firestore based on email
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userEmail).get();
        if (userDoc.exists) {
          setState(() {
            _username = responseBody["user"]["username"];
            _profileImageUrl = userDoc['profileImage']; // Fetch the image URL
            _isLoading = false;
          });
        } else {
          throw Exception('User data not found in Firestore');
        }
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
      setState(() {
        _isLoading = false; // Stopping loading evet if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 130),
              // Left-aligned title
              const Text(
                "Registration\nComplete",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Color.fromRGBO(68, 202, 233, 1),
                ),
              ),
              const SizedBox(height: 10),

              // Left-aligned description
              const Text(
                "Account has been created successfully",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const Text(
                "Go where your heart roams",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 80),

              // Centered profile picture with glow effect
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Loading indicator
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 20, 52, 66)
                                  .withOpacity(0.6),
                              blurRadius: 5,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(255, 149, 200, 243)
                                  .withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(
                                  _profileImageUrl!) // Display fetched profile image
                              : const AssetImage(
                                      'assets/profile_placeholder.png')
                                  as ImageProvider, // Fallback placeholder
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Centered username
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Loading indicator
                    : Text(
                        _username ?? "User", // Display fetched username
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 140),

              // Centered Explore Home button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 32, 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Explore Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
