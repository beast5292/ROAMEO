import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Home/home_page.dart';
import 'login_page.dart';
import 'open_page.dart';
import './setup_account_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.100.14:8000/signup');
    final Map<String, String> requestBody = {
      "username": _usernameController.text,
      "email": _emailController.text,
      "dob": _dobController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Store the JWT token and email
        await storage.write(key: 'jwt_token', value: responseBody["token"]);
        await storage.write(key: 'user_email', value: _emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Signup successful! Please login to continue.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetupAccountPage()),
        );
      } else {
        final errorMessage =
            responseBody["detail"] ?? "Signup failed. Please try again.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(3, 10, 14, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OpeningScreen()),
                    );
                  },
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 35,
                      shadows: [Shadow(color: Colors.white, blurRadius: 20)]),
                ),
                const SizedBox(height: 70),
                const Text("Sign up",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(68, 202, 233, 1))),
                const SizedBox(height: 10),
                _buildTextField(
                    icon: Icons.person,
                    hintText: "Username",
                    controller: _usernameController),
                const SizedBox(height: 15),
                _buildTextField(
                    icon: Icons.email,
                    hintText: "Email ID",
                    controller: _emailController),
                const SizedBox(height: 15),
                _buildTextField(
                    icon: Icons.calendar_today,
                    hintText: "DOB",
                    controller: _dobController),
                const SizedBox(height: 15),
                _buildTextField(
                    icon: Icons.lock,
                    hintText: "Enter Your Password",
                    controller: _passwordController,
                    obscureText: true),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 32, 46),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 142, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign up",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage())),
                    child: const Text("Already have an account? Login Now",
                        style:
                            TextStyle(color: Color.fromRGBO(68, 202, 233, 1))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required IconData icon,
      required String hintText,
      bool obscureText = false,
      required TextEditingController controller}) {
    return TextFormField(
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }
}
