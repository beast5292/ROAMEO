import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {"type": "like", "user": "Alex", "message": "liked your post.", "image": "lib/assets/images/cars1.jpg"},
    {"type": "comment", "user": "Sarah", "message": "commented: Nice post!", "image": "lib/assets/images/cars5.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(notification["image"]!),
            ),
            title: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white),
                children: [
                  TextSpan(text: notification["user"], style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " ${notification["message"]}"),
                ],
              ),
            ),
            trailing: notification["type"] == "follow"
                ? ElevatedButton(
              onPressed: () {},
              child: Text("Follow Back"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            )
                : null,
          );
        },
      ),
    );
  }
}
