import 'package:flutter/material.dart';
import 'nav_bar.dart'; // Import the NavBar widget

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selectedIndex = 3; // Default active tab

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Detail Page"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "This is a placeholder page to test the NavBar.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarItemTapped,
      ),
    );
  }
}