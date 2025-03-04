import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {"type": "like", "user": "Alex", "message": "liked your post.", "image": "lib/assets/images/cars1.jpg"},
    {"type": "comment", "user": "Sarah", "message": "commented: Nice post!", "image": "lib/assets/images/cars5.png"},
    {"type": "follow", "user": "Michael", "message": "started following you.", "image": "lib/assets/images/Logo.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,

    );
  }
}
