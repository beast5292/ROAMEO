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
    sightsFuture = fetchSights(); // Fetching sights from the API
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
            String docId = modes[index]['id']; // Firestore Document ID
            var sight = modes[index]['sights'].isNotEmpty 
                ? modes[index]['sights'][0] 
                : null;

            if (sight == null) return const SizedBox();

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
                      sight['modeName'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      sight['modeDescription'] ?? 'No Description',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Created by: ${sight['username'] ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print("View button pressed for docId $docId");
                            // Handle view action here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300], // Optional color change
                          ),
                          child: const Text(
                            "View",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8), // Space between buttons
                        ElevatedButton(
                          onPressed: () {
                            print("Play button pressed for docId $docId");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SsmPlay(
                                  index: index,
                                  docId: docId,
                                ),
                              ),
                            );
                          },
                          child: const Text("Play"),
                        ),
                      ],
                    ),
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
