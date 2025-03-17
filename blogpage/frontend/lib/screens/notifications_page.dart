import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('No new notifications', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
    );
  }
}