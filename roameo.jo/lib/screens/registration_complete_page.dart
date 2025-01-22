import 'package:flutter/material.dart';

class RegistrationCompletePage extends StatelessWidget {
  final String username; // Pass the username to this page

  const RegistrationCompletePage({Key? key, required this.username})
      : super(key: key);

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
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
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
                      BoxShadow(
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/profile_placeholder.png'), // Replace with actual image logic
                  ),
                ),
              ),
              const SizedBox(height: 10),

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
                    // Navigate to the Home Page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 32, 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
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
