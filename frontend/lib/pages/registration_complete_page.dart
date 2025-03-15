import 'package:flutter/material.dart';
import '../Home/home_page.dart';

class RegistrationCompletePage extends StatelessWidget {
  final String username; // Pass the username to this page

  const RegistrationCompletePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.start, // Left-align the content
            children: [
              const SizedBox(height: 130),
              // Left-aligned title
              const Text(
                "Registration\nComplete",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Color.fromRGBO(68, 202, 233, 1), // Title text color
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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Outershadow layer
                      BoxShadow(
                        color: Color.fromARGB(255, 20, 52, 66).withOpacity(0.6),
                        blurRadius: 5,
                        spreadRadius: 20,
                      ),

                      // Inner shadow layer
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 149, 200, 243).withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/profile_placeholder.png'), // Have to Replace with image logic
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Centered username
              Center(
                child: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 140,
              ),

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
