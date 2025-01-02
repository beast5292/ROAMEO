import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: googlePlex,
          zoom: 12,
        ),
      ),
    );
  }
}
