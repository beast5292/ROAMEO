import 'package:flutter/material.dart';
import 'location_model.dart'; 
import 'nav_bar.dart'; 

class DetailPage extends StatefulWidget {
  final Location location; // Accept a Location object

  const DetailPage({Key? key, required this.location}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selectedIndex = 3; 

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      body: Stack(
        children: [
          // Image Section w gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 470, // Adjust height 
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.location.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, // Start from the bottom
                    end: Alignment.topCenter, // End at the top
                    colors: [
                      Colors.black.withOpacity(1.0), // control transparency
                      Colors.transparent, // Fully transparent at the top
                    ],
                    stops: [0.0, 0.8], // Adjust the stops for the fade effect
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 75,
            left: 27,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Go back
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),

          // Rating Section 
          Positioned(
            top: 275, 
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 184, 102).withOpacity(0.7), // Yellow background and transparency
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // Shadow color
                    offset: Offset(0, 4), // Shadow position (x, y)
                    blurRadius: 10, // Blur effect
                    spreadRadius: 4, // Spread of the shadow
                  ),
                ], 
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: const Color.fromARGB(255, 254, 216, 65), size: 24), // Star icon
                  SizedBox(width: 8), // Spacing
                  Text(
                    "${widget.location.rating}",
                    style: TextStyle(
                      color: Color.fromARGB(255, 254, 216, 65),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Name of the Location 
          Positioned(
            top: 325, 
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
              child: Text(
                widget.location.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          // Description Section
          Positioned(
            top: 430, 
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              child: Text(
                widget.location.description,
                softWrap: true, // Automatically wraps text
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarItemTapped,
      ),
    );
  }
}