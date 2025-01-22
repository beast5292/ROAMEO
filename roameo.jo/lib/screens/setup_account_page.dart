import 'package:flutter/material.dart';
import 'registration_complete_page.dart';

class SetupAccountPage extends StatelessWidget {
  const SetupAccountPage({Key? key}) : super(key: key);

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
              // Back button

              SizedBox(height: 30), // Add spacing between elements
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.1),
                      blurRadius: 50,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title and description
              const Text(
                "Setup your\n account",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Finish your account setup by\n uploading your profile picture\n and setting your username.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Profile picture placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                          'assets/profile_placeholder.png'), // Placeholder image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Image picker logic will go here
                          },
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

              // Username field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  hintText: "Username",
                  hintStyle:
                      const TextStyle(color: Colors.white70, fontSize: 10),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 97, 91, 101),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 170),

              // Create account button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic for account creation
                    String username = "Username";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistrationCompletePage(username: username),
                      ),
                    );
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
                    "Create account",
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
