import 'package:flutter/material.dart';
import 'package:homepage/Sightseeingmode/camera_page.dart';
import 'package:homepage/location_search_screen.dart';

class SightMenu extends StatefulWidget {
  const SightMenu({super.key});

  @override
  State<SightMenu> createState() => _SightMenuState();
}

class _SightMenuState extends State<SightMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Text("Create your own sightseeing mode"),
              ],
            ),
          ),
          Positioned(
            top: 600,
            right: 10,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchLocationScreen()),
                  );
                },
                child: Icon(Icons.map)),
          ),
          Positioned(
            top: 700,
            right: 10,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                child: Icon(Icons.camera)),
          ),
        ],
      ),
    );
  }
}
