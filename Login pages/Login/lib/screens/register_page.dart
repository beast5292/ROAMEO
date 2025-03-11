import 'package:flutter/material.dart';
import 'package:roameo/screens/setup_account_page.dart';
import 'package:roameo/screens/login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromRGBO(3, 10, 14, 1), // Background text colour
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Back button with glow effect
              Container(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      // Arrow Icon
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 35,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 70),

              // Title
              const Text(
                "Sign up",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Color.fromRGBO(68, 202, 233, 1), // Title text color
                ),
              ),
              const SizedBox(height: 10),

              // Full name field
              _buildTextField(
                icon: Icons.person,
                hintText: "Full Name",
              ),
              const SizedBox(height: 15),

              // Email ID field
              _buildTextField(
                icon: Icons.email,
                hintText: "Email ID",
              ),
              const SizedBox(height: 15),

              // DOB field
              _buildTextField(
                icon: Icons.calendar_today,
                hintText: "DOB",
              ),
              const SizedBox(height: 15),

              // Password field with "Forgot Password?"
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  _buildTextField(
                    icon: Icons.lock,
                    hintText: "Enter Your Password",
                    obscureText: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        // Add forgot password logic here
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Color.fromRGBO(
                              68, 202, 233, 1), // Forgot password text color
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Sign up button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupAccountPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 2, 32, 46), // Button background color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 142, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // "or sign up with" text
              Center(
                child: Column(
                  children: [
                    const Text(
                      "or sign up with",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Social sign-up buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google option
                        _buildSocialButton(
                          imagePath: 'assets/google.png',
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Google sign-up logic
                          },
                        ),
                        const SizedBox(width: 20),

                        // Apple Option
                        _buildSocialButton(
                          icon: Icons.apple,
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Apple sign-up logic
                          },
                        ),
                        const SizedBox(width: 20),

                        // Facebook Option
                        _buildSocialButton(
                          icon: Icons.facebook,
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Facebook sign-up logic
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Footer
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.white70),
                    children: [
                      WidgetSpan(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login Now",
                          style: TextStyle(
                              color: Color.fromRGBO(68, 202, 233, 1),
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for text fields
  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true,
        fillColor:
            const Color.fromARGB(166, 103, 102, 1118), //Text field fill colour
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Helper widget for social buttons
  Widget _buildSocialButton({
    IconData? icon,
    String? imagePath,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  color: Colors.white,
                  width: 28,
                  height: 28,
                )
              : Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
