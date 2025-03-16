import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Feed/SightFeed.dart';
import 'package:practice/SightSeeingMode/Menu.dart';

class SsmPage extends StatefulWidget {
  const SsmPage({super.key});

  @override
  _SsmPageState createState() => _SsmPageState();
}

class _SsmPageState extends State<SsmPage> {
  static const googlePlex = LatLng(37.4223, -122.0848);
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _showDetails = false;
  String _selectedScenery = 'temporary';
  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/map_styles/dark_mode.json').then((string) {
      _mapStyle = string;
    });
  }

  void _loadMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId("temporary1"),
          position: const LatLng(37.425, -122.08),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () => setState(() => _showDetails = true),
        ),
        Marker(
          markerId: const MarkerId("permanent1"),
          position: const LatLng(37.42, -122.085),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          onTap: () => setState(() => _showDetails = true),
        ),
      ]);
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      final markerId = MarkerId(position.toString());
      final icon = _selectedScenery == 'temporary'
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

      _markers.add(
        Marker(
          markerId: markerId,
          position: position,
          icon: icon,
          onTap: () => setState(() => _showDetails = true),
        ),
      );
    });
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: const Color(0xFF030A0E).withOpacity(0.8),
            title: const Text("Select Scenery Type", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Temporary", style: TextStyle(color: Colors.white)),
                  leading: Radio(
                    fillColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                    value: "temporary",
                    groupValue: _selectedScenery,
                    onChanged: (value) => _updateScenery(value.toString(), context),
                  ),
                ),
                ListTile(
                  title: const Text("Permanent", style: TextStyle(color: Colors.white)),
                  leading: Radio(
                    fillColor: MaterialStateColor.resolveWith((states) => Colors.cyan),
                    value: "permanent",
                    groupValue: _selectedScenery,
                    onChanged: (value) => _updateScenery(value.toString(), context),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Confirm", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateScenery(String value, BuildContext context) {
    setState(() => _selectedScenery = value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: googlePlex,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              mapController = controller;
              controller.setMapStyle(_mapStyle);
            },
            onTap: _addMarker,
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Search Bar with QR Icon
          Positioned(
            top: 50,
            left: 80,
            right: 20,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(Icons.search, color: Colors.white70),
                  ),
                  Expanded(
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search locations...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white70),
                    onPressed: () {}, // Add QR functionality
                  ),
                ],
              ),
            ),
          ),

          // Background tap to close details
          if (_showDetails)
            GestureDetector(
              onTap: () => setState(() => _showDetails = false),
              behavior: HitTestBehavior.opaque,
            ),

          // Details Panel
          if (_showDetails)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF030A0E).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Beautiful Scenery", 
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _showDetails = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/rectangle 24.png'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.5),
                              Colors.cyan.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {}, 
                          child: const Text("EXPLORE", 
                            style: TextStyle(color: Colors.white))
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Buttons
          Positioned(
            bottom: 30,
            left: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildGlassButton(
                  icon: Icons.add_location,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SightMenu()),
                  ),
                ),
                const SizedBox(width: 15),
                _buildGlassButton(
                  icon: Icons.list,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SightFeed()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}