import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/Services/SightGet.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Ssmplay.dart';


class SightFeed extends StatefulWidget {
  const SightFeed({super.key});

  @override
  State<SightFeed> createState() => _SightFeedState();

}

class _SightFeedState extends State<SightFeed> {
  late Future<List<dynamic>> sightsFuture;

  @override
  void initState() {
    super.initState();
    sightsFuture = fetchSights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sightseeing Feed")),
      body: FutureBuilder<List<dynamic>>(
        future: sightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No sightseeing modes available"));
          }

          List<dynamic> modes = snapshot.data!;

          return ListView.builder(
            itemCount: modes.length,
            itemBuilder: (context, index) {
              List<dynamic> sights = modes[index];

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sightseeing Mode ${index + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: sights.map((sight) {
                          return ListTile(
                            title: Text(sight['name'] ?? 'No Name'),
                            subtitle:
                                Text(sight['description'] ?? 'No Description'),
                          );
                        }).toList(),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle play button press
                            print("Play button pressed for mode ${index + 1}");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SsmPlay(index:index)),
                            );
                          },
                          child: const Text("Play"),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
