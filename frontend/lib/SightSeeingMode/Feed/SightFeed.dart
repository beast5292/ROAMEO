import 'package:flutter/material.dart';
import 'package:practice/SightSeeingMode/Services/SightGet.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Ssmplay.dart';
import 'package:practice/SightSeeingMode/Simulation/pages/Ssmview.dart';
import 'package:practice/SightSeeingMode/Services/SightSearch.dart';

class SightFeed extends StatefulWidget {
  const SightFeed({super.key});

  @override
  State<SightFeed> createState() => _SightFeedState();
}

class _SightFeedState extends State<SightFeed> {
  late Future<List<dynamic>> sightsFuture;
  TextEditingController searchController =
      TextEditingController(); // Controller for search bar-----------
  String searchQuery = ""; // Stores the search query ----------------

  @override
  void initState() {
    super.initState();
    sightsFuture = fetchSights(); // Fetching sights from the API
  }

  // Function to handle search based on user input----------------
  void performSearch() {
    setState(() {
      String query = searchController.text.trim();
      print("Search query for: $query");
      try {
        if (query.isEmpty) {
          print("Fetching all sights");
          sightsFuture = fetchSights();
        } else {
          print("Fetching search results");
          sightsFuture = searchSights(query);
        }
      } catch (e) {
        print("Search error: $e");
      }
    });
  }

  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sightseeing Feed"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                    "Search sightseeing modes", // Placeholder text -------------
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    print("Search button pressed");
                    performSearch();
                  },
                ), // Search Icon

                /// Search icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                print("Enter key pressed");
                performSearch(); // Call search function when user types
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: sightsFuture,
        builder: (context, snapshot) {
          print("Snapshot state: ${snapshot.connectionState}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return const Center(child: Text("No sightseeing modes available"));
          }

          List<dynamic> modes = snapshot.data!; // Extract sightseeing mode data
          print("Fetched ${modes.length} results");

          return ListView.builder(
            itemCount: modes.length, // Number of items in the list
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
                        "Created by: ${sight['username'] ?? 'Unknown'}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Created by: ${sight['username'] ?? 'Unknown'}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print("View button pressed for docId $docId");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SsmView(
                                    index: index,
                                    docId: docId,
                                  ),
                                ),
                              );
                              // Handle view action here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.grey[300], // Optional color change
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
