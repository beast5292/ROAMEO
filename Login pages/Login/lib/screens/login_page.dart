import 'package:flutter/material.dart';
import 'package:roameo/screens/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(3, 10, 14, 1), // Background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Back button
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

              const SizedBox(height: 90),

              // Title
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(68, 202, 233, 1),
                ),
              ),
              const SizedBox(height: 40),

              // Email/Username Text Field
              _buildTextField(
                icon: Icons.email,
                hintText: "Enter your email / username",
              ),
              const SizedBox(height: 30),

              // Password Text Field
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
                        // Add forgot password logic
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Color.fromRGBO(68, 202, 233, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Login Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add login logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(2, 32, 46, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),

              // "or Login With" text
              Center(
                child: Column(
                  children: [
                    const Text(
                      "or Login With",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          imagePath: 'assets/google.png',
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Google login logic
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.apple,
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Apple login logic
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          color: const Color.fromRGBO(68, 202, 233, 1),
                          onPressed: () {
                            // Add Facebook login logic
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
                    text: "New user? ",
                    style: const TextStyle(color: Colors.white70),
                    children: [
                      WidgetSpan(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register Here",
                          style: TextStyle(
                            color: Color.fromRGBO(68, 202, 233, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
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
