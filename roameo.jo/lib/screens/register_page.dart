import 'package:flutter/material.dart';
import 'package:roameo/screens/setup_account_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            // Here starts the elemnts for the page
            children: [
              // Back button
              // SizedBox(height: 30), // Add spacing between elements
              // IconButton(
              //   onPressed: () {
              //     Navigator.pop(context); // Go back to the previous screen
              //   },
              //   icon: Icon(
              //     Icons.arrow_back_ios_new_rounded,
              //     color: Colors.white,
              //   ),
              // ),

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
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Register title
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 10),

              // Full name field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white70),
                  hintText: "Full name",
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 10),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 97, 91, 101),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Email ID field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.white70),
                  hintText: "Email ID",
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 10),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 97, 91, 101),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // // Password field
              // TextField(
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     prefixIcon: Icon(Icons.lock, color: Colors.white70),
              //     suffixText: "Forgot password?",
              //     suffixStyle: TextStyle(color: Colors.lightBlueAccent),
              //     hintText: "Enter Your Password",
              //     hintStyle: TextStyle(color: Colors.white70),
              //     filled: true,
              //     fillColor: Colors.grey.shade800,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(40),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 40),

              // Password field
              Stack(
                alignment: Alignment.center,
                children: [
                  // TextField for the password input
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      hintText: "Enter Your Password",
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 10),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 97, 91, 101),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  // Positioned Forgot password text
                  Positioned(
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        // Add forgot password logic
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Register button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SetupAccountPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 32, 46),
                    padding:
                        EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Social sign-up options
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/face_recognition.png',
                      color: Colors.white,
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Sign up with",
                      style: TextStyle(
                        color: const Color.fromARGB(179, 159, 185, 186),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google button
                        SocialButton(
                          icon: Icons.g_mobiledata,
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            // Add Google sign-up logic
                          },
                        ),
                        const SizedBox(width: 30),

                        // Apple button
                        SocialButton(
                          icon: Icons.apple,
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            // Add Apple sign-up logic
                          },
                        ),
                        const SizedBox(width: 30),

                        // Facebook button
                        SocialButton(
                          icon: Icons.facebook,
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            // Add Facebook sign-up logic
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),

              // Footer
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Login Now",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
