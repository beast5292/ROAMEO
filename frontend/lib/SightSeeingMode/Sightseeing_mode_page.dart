import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practice/SightSeeingMode/Menu.dart';

class SsmPage extends StatefulWidget {
  const SsmPage({super.key});

  @override
  _SsmPageState createState() => _SsmPageState();
}

class _SsmPageState extends State<SsmPage> {
  static const LatLng googlePlex = LatLng(37.4223, -122.0848);
  late final GoogleMapController mapController;
  final Map<MarkerId, Marker> _markers = {}; // Optimized marker storage
  bool _showDetails = false;
  String _selectedScenery = 'temporary';

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    _addMarker(const LatLng(37.425, -122.08), "temporary1", true);
    _addMarker(const LatLng(37.42, -122.085), "permanent1", false);
  }

  void _addMarker(LatLng position, String id, bool isTemporary) {
    final markerId = MarkerId(id);
    final icon = isTemporary
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

    setState(() {
      _markers[markerId] = Marker(
        markerId: markerId,
        position: position,
        icon: icon,
        onTap: () => setState(() => _showDetails = true),
      );
    });
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Scenery Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["temporary", "permanent"].map((type) {
              return RadioListTile(
                title: Text(type.capitalize()),
                value: type,
                groupValue: _selectedScenery,
                onChanged: (value) {
                  setState(() => _selectedScenery = value.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: googlePlex, zoom: 12),
            markers: _markers.values.toSet(),
            onMapCreated: (controller) => mapController = controller,
            onTap: (position) => _addMarker(
                position, position.toString(), _selectedScenery == "temporary"),
          ),
          const Positioned(top: 40, left: 10, right: 10, child: _SearchBar()),
          if (_showDetails)
            const Positioned(
                bottom: 120, left: 20, right: 20, child: _DetailPopup()),
          const Positioned(
              bottom: 20, left: 20, right: 20, child: _BottomCarousel()),
          Positioned(
            bottom: 200,
            right: 20,
            child: Column(
              children: [
                _FloatingButton(
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SightMenu()));
                    }),
                const SizedBox(height: 10),
                _FloatingButton(icon: Icons.edit, onPressed: _showEditDialog),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ Extracted Widgets ------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {}),
      ],
    );
  }
}

class _DetailPopup extends StatelessWidget {
  const _DetailPopup();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Image.network("https://via.placeholder.com/100"),
          const Text("Beautiful Scenery",
              style: TextStyle(color: Colors.white)),
          TextButton(onPressed: () {}, child: const Text("EXPLORE")),
        ],
      ),
    );
  }
}

class _BottomCarousel extends StatelessWidget {
  const _BottomCarousel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Image.network("https://via.placeholder.com/100"),
                const Text("Popular Place",
                    style: TextStyle(color: Colors.white)),
                TextButton(onPressed: () {}, child: const Text("EXPLORE")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

// ------------------ Utility Extension ------------------
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
