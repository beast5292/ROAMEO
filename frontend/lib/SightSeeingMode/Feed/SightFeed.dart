import 'dart:async';
import 'dart:ui';

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
  bool _minimumTimePassed = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // Start both timer and data loading
    sightsFuture = fetchSights().then((value) {
      _dataLoaded = true;
      return value;
    }).catchError((error) {
      _dataLoaded = true; // Ensure loading state exits on error
      throw error;
    });

    // Force minimum 0.3 second loading duration (300ms)
    Timer(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() => _minimumTimePassed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A0E),
      appBar: AppBar(
        title: const Text("Sightseeing Feed",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: sightsFuture,
        builder: (context, snapshot) {
          // Show loading until both conditions are met
          final showLoading = !_minimumTimePassed || !_dataLoaded;
          
          if (showLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Loading Roams",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.1,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No sightseeing modes available",
                    style: TextStyle(color: Colors.white)));
          }

          List<dynamic> modes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modes.length,
            itemBuilder: (context, index) {
              String docId = modes[index]['id'];
              List<dynamic> sights = modes[index]['sights'];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sightseeing Mode ${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...sights.map((sight) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(sight['name'] ?? 'No Name',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)),
                            subtitle: Text(
                              sight['description'] ?? 'No Description',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14),
                            ),
                          )).toList(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 50, 153, 255)
                                        .withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow, size: 32),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SsmPlay(
                                          index: index, docId: docId),
                                    ),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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