import 'package:flutter/material.dart';
import 'register_page.dart'; // Import the register page

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020C0E), // Dark background color
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 90),

              // Logo with motto
              Image.asset(
                'assets/Logo&motto.png',
                width: 300,
                height: 250,
              ),
              const SizedBox(height: 180), // Space between logo and button

              // Glowing button
              GestureDetector(
                onTap: () {
                  // Navigate to the Register page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 53, 94, 113),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlueAccent.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 35,
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
