import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';

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
                       builder: (context) => PlacesAutoCompleteField(
                                apiKey: 'AIzaSyC3G2HDD7YggkkwOPXbp_2sBnUFR3xCBU0', // Pass the actual API key here
                     ),
                    )
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
