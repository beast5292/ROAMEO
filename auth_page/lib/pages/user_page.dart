import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.account_circle, size: 100),
            SizedBox(height: 20),
            Text(
              "Welcome to your account!",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
