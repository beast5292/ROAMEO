import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './sign_up_page.dart';
import './setup_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      // Stop the process if the form data is not valid
      return;
    }

    setState(() => _isLoading = true);
    final url = Uri.parse('http://192.168.100.14:8000/login');
    final requestBody = {
      "email": _emailController.text,
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
        await storage.write(key: 'jwt_token', value: responseBody["token"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetupAccountPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody["detail"] ?? "Invalid credentials")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(3, 10, 14, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            // Assigning the form key
            key: _formKey,
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
                          color: Colors.white.withOpacity(0.5), blurRadius: 40),
                    ],
                  ),
                ),
                SizedBox(height: 90),
                Text("Login",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(68, 202, 233, 1))),
                SizedBox(height: 40),
                _buildTextField(Icons.email, "Enter your email / username",
                    _emailController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                SizedBox(height: 30),
                _buildTextField(
                    Icons.lock, "Enter Your Password", _passwordController,
                    obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                }),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(2, 32, 46, 1),
                      padding:
                          EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 70),
                Center(
                    child: Text("or Login With",
                        style: TextStyle(color: Colors.white70, fontSize: 16))),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.apple),
                    SizedBox(width: 20),
                    _buildSocialButton(Icons.facebook),
                  ],
                ),
                Spacer(),
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
                                    builder: (context) => SignUpPage())),
                            child: Text("Register Here",
                                style: TextStyle(
                                    color: Color.fromRGBO(68, 202, 233, 1),
                                    fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller,
      {bool obscureText = false, String? Function(String?)? validator}) {
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
            borderSide: BorderSide.none),
      ),
      // Adding validator
      validator: validator,
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Color.fromRGBO(68, 202, 233, 1), size: 30),
      onPressed: () {},
    );
  }
}
