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

  /// Handles sign-up process
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('https://roameo-449418.uc.r.appspot.com/signup');
    final requestBody = jsonEncode({
      "username": _usernameController.text,
      "email": _emailController.text,
      "dob": _dobController.text,
      "password": _passwordController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      final responseBody = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        await storage.write(key: 'jwt_token', value: responseBody["token"]);
        await storage.write(key: 'user_email', value: _emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✔ Signup successful! Please log in.')),
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SetupAccountPage()));
      } else {
        final errorMessage = responseBody["detail"] ?? "Signup failed!";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("⚠ $errorMessage")));
      }
    } catch (_) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error: Server unreachable')),
      );
    }
  }

  /// Function to pick date using a date picker
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent keyboard overflow
      backgroundColor: const Color.fromRGBO(3, 10, 14, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          // Prevents overflow when keyboard appears
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 35,
                        shadows: const [
                          Shadow(color: Colors.white, blurRadius: 20)
                        ]),
                  ),
                  const SizedBox(height: 70),
                  const Text("Sign up",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(68, 202, 233, 1))),
                  const SizedBox(height: 10),

                  /// Username Field
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(Icons.person, "Username"),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter username' : null,
                  ),
                  const SizedBox(height: 15),

                  /// Email Field
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(Icons.email, "Email ID"),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 15),

                  /// DOB Field with Date Picker
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(Icons.calendar_today, "DOB"),
                    onTap: _pickDate, // Open date picker on tap
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter DOB' : null,
                  ),
                  const SizedBox(height: 15),

                  /// Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        _inputDecoration(Icons.lock, "Enter Your Password"),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter password' : null,
                  ),
                  const SizedBox(height: 15),

                  /// Sign-up Button
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Login Navigation
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage())),
                      child: const Text("Already have an account? Login Now",
                          style: TextStyle(
                              color: Color.fromRGBO(68, 202, 233, 1))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Input Decoration Helper
  InputDecoration _inputDecoration(IconData icon, String hintText) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      filled: true,
      fillColor: const Color.fromARGB(166, 103, 102, 118), // Fixed fillColor
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
    );
  }
}
