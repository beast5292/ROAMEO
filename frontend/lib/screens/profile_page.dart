import 'package:flutter/material.dart';
import 'package:bloge/screens/notifications_page.dart';
import 'SettingsPage.dart';

class ProfilePage extends StatefulWidget {
  final int numberOfPosts; // Receive the number of posts as a parameter

  const ProfilePage({Key? key, required this.numberOfPosts}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              color: Colors.black,
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('lib/assets/images/cars5.png'), // Replace with user's image
                  ),
                  SizedBox(height: 10),
                  // Username
                  Text(
                    'UserName', // Replace with dynamic username
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
                    child: Text(
                      'STATUS   ONLINE',
                      style: TextStyle(color: Colors.greenAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Stats: Followers, Following, Posts
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat('Posts', widget.numberOfPosts), // Display number of posts here
                        SizedBox(width: 30),
                        _buildStat('Likes', 0),
                        SizedBox(width: 30),
                        _buildStat('Dislikes', 0),
                      ],
                    ),
                  ),
                  // Settings button
                  Divider(color: Colors.white24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0), // Optional: Add padding for spacing
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                        children: [
                          // Settings Button
                          TextButton.icon(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Settings',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SettingsPage()),
                              );
                            },
                          ),
                          // Notifications Button
                          Divider(color: Colors.white24),
                          TextButton.icon(
                            icon: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Notifications',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NotificationsPage()),
                              );
                            },
                          ),
                          Divider(color: Colors.white24),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // method to create stat text
  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
