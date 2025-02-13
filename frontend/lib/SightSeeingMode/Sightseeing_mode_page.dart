import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Feed/SightFeed.dart';
import 'package:practice/SightSeeingMode/Menu.dart';
import 'package:google_maps_webservice/places.dart';

class SsmPage extends StatefulWidget {
  const SsmPage({super.key});

  @override
  _SsmPageState createState() => _SsmPageState();
}

class _SsmPageState extends State<SsmPage> {
  static const googlePlex = LatLng(37.4223, -122.0848);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sightseeing Mode'),
        ),
        body: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: googlePlex,
              zoom: 12,
            ),
          ),
          Positioned(
            top: 500,
            right: 20,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SightMenu()),
                  );
                },
                child: Icon(Icons.create)),
          ),
          Positioned(
            top: 600,
            right: 20,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SightFeed()),
                  );
                },
                child: Icon(Icons.search)),
          )
        ]));
  }
}
