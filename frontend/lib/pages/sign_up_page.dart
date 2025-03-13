import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
          backgroundColor: Colors.white, // Adjust the app bar color
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'DOB',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Your Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity, // Match the width of the text fields
                height: 50.0, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    // Handle sign up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button background color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: Text('Sign Up'),
                ),
              ),
              SizedBox(height: 16.0),
              Text('or sign up with'),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: SizedBox(
                      width: 48.0, // Set the width
                      height: 48.0, // Set the height
                      child: Image.asset('assets/images/google_icon.jpg'),
                    ),
                    onPressed: () {
                      // Handle Google sign up
                    },
                  ),
                  IconButton(
                    icon: SizedBox(
                      width: 48.0, // Set the width
                      height: 48.0, // Set the height
                      child: Image.asset('assets/images/facebook_icon.jpg'),
                    ),
                    onPressed: () {
                      // Handle Facebook sign up
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  // Navigate to login page
                },
                child: Text(
                  'Already have an account? Login Now',
                  style: TextStyle(color: Colors.blue), // Text color
                ),
              ),
            ],
          ),
        ));
  }
}
