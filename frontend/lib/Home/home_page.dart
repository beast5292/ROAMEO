import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:practice/SightSeeingMode/Sightseeing_mode_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPillSwitchOn = false; // State for the pill switch
  int _selectedIndex = 0; // To keep track of selected icon
  final storage = FlutterSecureStorage(); // For securely storing the JWT token
  Map<String, dynamic>? userData; // To store user information

  @override
  void initState() {
    super.initState();
    // Fetching the user data when the page loads
    fetchUserData();
  }

  // Fetching the user data from the backend
  Future<void> fetchUserData() async {
    try {
      final String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found");
        return;
      }

      final url = Uri.parse('http://192.168.100.14:8000/user');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          userData = responseBody["user"];
        });
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  // Method to get greeting based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning, ${userData?["name"] ?? "User"}!';
    } else if (hour >= 12 && hour < 15) {
      return 'Good Afternoon, ${userData?["name"] ?? "User"}!';
    } else {
      return 'Good Evening, ${userData?["name"] ?? "User"}!';
    }
  }

  // Handle tap on a navigation icon
  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Navigation icon $index tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // World Image behind the content
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to SsmPage when the world image is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SsmPage()),
                    );
                  },
                  child: Container(
                    width: 360,
                    height: 370,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/world.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content on top of the world image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 23),
                          Text(
                            getGreeting(),
                            style: TextStyle(
                              color: const Color(0xFF6B8292),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Start ",
                                  style: TextStyle(
                                    color: const Color(0xFF44CAE9),
                                    fontSize: 33,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: "here\n",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w200),
                                ),
                                TextSpan(
                                  text: "Roam ",
                                  style: TextStyle(
                                    color: const Color(0xFF44CAE9),
                                    fontSize: 33,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: "everywhere\n",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w200),
                                ),
                                TextSpan(
                                  text: "Love ",
                                  style: TextStyle(
                                    color: const Color(0xFF44CAE9),
                                    fontSize: 33,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: "every mile",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => print("Profile picture tapped"),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage('assets/images/profile.jpg'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 220),

                  // Categories Section with Glassmorphism
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildGlassSearchIcon(),
                      SizedBox(width: 7),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGlassCategoryChip("Happy"),
                            _buildGlassCategoryChip("Excited"),
                            _buildGlassCategoryChip("Adventurous"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Grid Section
                  Row(
                    children: [
                      // Left card
                      Expanded(
                        child: _buildGridCard(
                          "Ella",
                          "assets/images/longrectangle.png",
                          height: 250,
                          textSize: 24,
                          onTap: () => print("Ella card tapped"),
                        ),
                      ),
                      SizedBox(width: 8),

                      // Right side container with two smaller cards
                      Column(
                        children: [
                          _buildGridCard(
                            "ETA: 3:45PM\n\n\n\nNine Arch Bridge",
                            "assets/images/rectangle 25.png",
                            height: 128,
                            includeSwitch: true,
                            textSize: 14,
                            onTap: () => print("Nine Arch Bridge card tapped"),
                          ),
                          SizedBox(height: 7),
                          _buildGridCard(
                            "Hotel Onrock\n\n\n\n20h43mins",
                            "assets/images/rectangle 24.png",
                            height: 115,
                            textSize: 12,
                            onTap: () => print("Hotel Onrock card tapped"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 26.0),
        child: Container(
          height: 60,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIconWithImage(
                  'assets/icons/Icon1onclick.png', 'assets/icons/icon1.png', 0),
              _buildNavIconWithImage(
                  'assets/icons/icon2.png', 'assets/icons/icon2.png', 1),
              _buildNavIconWithImage(
                  'assets/icons/aiicon.ico', 'assets/icons/aiicon.ico', 2),
              _buildNavIconWithImage('assets/icons/exploreicon.png',
                  'assets/icons/exploreonclick.png', 3),
              _buildNavIconWithImage('assets/icons/feedicon.png',
                  'assets/icons/feedonclick.png', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSearchIcon() {
    return GestureDetector(
      onTap: () => print("Search button tapped"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color:
              Color.fromARGB(192, 103, 102, 118), // Apply transparency (18.5%)
          borderRadius: BorderRadius.circular(90),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white),
            Text(
              "",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCategoryChip(String label) {
    return GestureDetector(
      onTap: () => print("$label chip tapped"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color:
              Color.fromARGB(192, 103, 102, 118), // Apply transparency (18.5%)
          borderRadius: BorderRadius.circular(18.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String imagePath, {
    double height = 100,
    bool includeSwitch = false,
    double textSize = 16,
    Alignment textAlign = Alignment.bottomLeft,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: textAlign,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: textSize,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ),
            if (includeSwitch)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    // Rotating Compass Image Icon
                    SizedBox(width: 20),
                    // Custom Switch Thumb with GestureDetector
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isPillSwitchOn = !isPillSwitchOn;
                        });
                        print("Switch toggled: $isPillSwitchOn");
                      },
                      child: Container(
                        width: 50,
                        height: 29,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isPillSwitchOn
                              ? Color(0xFF253745)
                              : Color(0xFF676676),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: isPillSwitchOn
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: AnimatedRotation(
                              turns: isPillSwitchOn
                                  ? 0.5
                                  : 0, // Rotate 180 degrees (0.5 turn)
                              duration: Duration(milliseconds: 300),
                              child: Image.asset(
                                'assets/icons/compass.png', // Custom thumb icon
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIconWithImage(String iconPath, String activePath, int index) {
    bool isSelected = _selectedIndex == index;
    double iconSize = (index == 2) ? 60 : 35; // AI orb icon larger size
    return GestureDetector(
      onTap: () => _onNavBarItemTapped(index),
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1,
        duration: Duration(milliseconds: 100),
        child: Image.asset(
          isSelected ? activePath : iconPath,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
