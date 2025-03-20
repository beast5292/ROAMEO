import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';

class SightMenu extends StatefulWidget {
  const SightMenu({super.key});

  @override
  State<SightMenu> createState() => _SightMenuState();
}

class _SightMenuState extends State<SightMenu> {
  
  //api key
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

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
                                apiKey: apiKey, // Pass the actual API key here
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
