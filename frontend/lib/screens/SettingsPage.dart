import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Settings Options
            ListTile(
              title: Text('Change Username', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Add functionality to change username
              },
            ),
            Divider(color: Colors.white24),
            ListTile(
              title: Text('Change Password', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Add functionality to change password
              },
            ),
            Divider(color: Colors.white24),
            ListTile(
              title: Text('Notification Settings', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Add functionality for notification settings
              },
            ),
            Divider(color: Colors.white24),
            ListTile(
              title: Text('Privacy Settings', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Add functionality for privacy settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
