import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './SignUp_Page.dart';
import '../Home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;
  final storage = FlutterSecureStorage(); // Store authentication token

  // User login process
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stops login if fields are invalid
    }

    setState(() => _isLoading = true); // Loading animation

    final url = Uri.parse(
        'https://roameo-449418.uc.r.appspot.com/login'); // API endpoint for login
    final requestBody = {
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
    }; // Request body for login

    try {
      // HTTP POST request to login endpoint
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Decode JSON body
      final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200) {
        // Store JWT token(secured)
        await storage.write(key: 'jwt_token', value: responseBody["token"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        ); // Success message

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        ); // Navigate to home
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token expired. Please sign up again.')),
        ); // Handle token expiration

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignUpPage()),
        ); // Redirect to signup
      } else {
        // Invalid login handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody["detail"] ?? "Invalid credentials")),
        );
      }
    } catch (_) {
      // Handle connection errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }

    setState(() => _isLoading = false); // Stop loading animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Stopping the keyboard overflow
      backgroundColor: Color.fromRGBO(3, 10, 14, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey, // Form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 35,
                      shadows: [
                        Shadow(color: Colors.white, blurRadius: 20),
                        Shadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: 90),
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(68, 202, 233, 1),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Email input field
                  _buildTextField(
                    icon: Icons.email,
                    hintText: "Enter your email",
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20), //Spacing for next field

                  // Password input field
                  _buildTextField(
                    icon: Icons.lock,
                    hintText: "Enter Your Password",
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  // Login button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(2, 32, 46, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 70),
                  // Registration prompt
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "New user? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
                              ),
                              child: Text(
                                "Register Here",
                                style: TextStyle(
                                  color: Color.fromRGBO(68, 202, 233, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // text fields with error handling
  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            filled: true,
            fillColor: Color.fromARGB(166, 103, 102, 1118),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator, //Error message displayed below input
        ),
        SizedBox(height: 5), //Spacing for error messages
      ],
    );
  }
}
