import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPillSwitchOn = false; // State for the pill switch
  int _selectedIndex = 0; // To keep track of selected icon
  int _clickedIndex = -1; // To keep track of the clicked index (initially none)

  // Method to get greeting based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning, Sulaiman!';
    } else if (hour >= 12 && hour < 15) {
      return 'Good Afternoon, Sulaiman!';
    } else {
      return 'Good Evening, Sulaiman!';
    }
  }

  // Handle tap on a navigation icon
  void _onNavBarItemTapped(int index) {
    setState(() {
      if (_clickedIndex == index) {
        _clickedIndex = -1; // Reset if clicked twice
      } else {
        _clickedIndex = index; // Set clicked index
      }
      _selectedIndex = index; // Update selected index
    });
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
                child: Container(
                  width: 350, // Adjust the size for visible portion
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/world.png'), // Globe image
                      fit: BoxFit.cover,
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
                  // Greeting Section (Fixed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                            'assets/images/profile.jpg'), // Replace with your image
                      ),
                    ],
                  ),
                  SizedBox(height: 250),

                  // Categories Section with Search Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Search button
                      CircleAvatar(
                        radius: 20, // Larger and rounded search button
                        backgroundColor:
                            const Color(0xFF676676), // Light blue color
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRoundedCategoryChip("Happy"),
                            _buildRoundedCategoryChip("Excited"),
                            _buildRoundedCategoryChip("Adventurous"),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                  SizedBox(height: 1),

                  // Grid Section with Custom Heights for Each Card
                  Row(
                    children: [
                      // Left card
                      Expanded(
                        child: _buildGridCard(
                          "Ella",
                          "assets/images/longrectangle.png",
                          height: 250,
                          textSize: 24, // Larger text size for the title
                        ),
                      ),
                      SizedBox(width: 15), // Space between the cards

                      // Right side container with the two smaller cards
                      Column(
                        children: [
                          // Nine Arch Bridge card with pill switch
                          _buildGridCard(
                            "Nine Arch Bridge\nETA: 3:45PM\n\n\n",
                            "assets/images/rectangle 25.png",
                            height: 115,
                            includeSwitch: true, // Pass this as a parameter
                            textSize: 13,
                          ),
                          SizedBox(height: 7), // Space between the cards

                          // Hotel Onrock card
                          _buildGridCard(
                            "Hotel Onrock\n\n\n\n20h43mins",
                            "assets/images/rectangle 24.png",
                            height: 115,
                            textSize: 12,
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
      // Custom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Ensures even spacing
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

  // Helper function for rounded category chips
  Widget _buildRoundedCategoryChip(String label) {
    return GestureDetector(
      onTap: () {
        // Add your desired action here, for example:
        print('$label tapped');
        // You can change the state or navigate, depending on your use case
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF676676), // Light blue color
          borderRadius: BorderRadius.circular(18.7), // More rounded corners
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Helper function for Grid Cards
  Widget _buildGridCard(
    String title,
    String imagePath, {
    double height = 100,
    bool includeSwitch = false,
    double textSize = 16, // New parameter for text size
    Alignment textAlign =
        Alignment.bottomLeft, // Optional parameter to change text alignment
  }) {
    return Container(
      width: 180, // Control the width to match your design needs
      height: height, // Control the height dynamically
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Title with customizable text alignment and size
          Align(
            alignment: textAlign, // Dynamic alignment
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: textSize, // Dynamic text size
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ),

          // Pill Switch (conditionally displayed)
          if (includeSwitch)
            Positioned(
              top: 4.2,
              right: -3,
              child: Transform.scale(
                scale: 0.7, // Adjust size of the switch
                child: Switch(
                  value: isPillSwitchOn,
                  onChanged: (value) {
                    setState(() {
                      isPillSwitchOn = value;
                    });
                  },
                  activeColor: Color(0xFF6B8292),
                  activeTrackColor: Color(0xFF253745),
                  inactiveThumbColor: Color(0xFF253745),
                  inactiveTrackColor: Color.fromARGB(255, 151, 153, 165),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Function to build each nav icon with active/inactive states
  Widget _buildNavIconWithImage(String iconPath, String activePath, int index) {
    bool isSelected = _selectedIndex == index;
    double iconSize = (index == 2) ? 60 : 38; // Larger size for AI icon
    return GestureDetector(
      onTap: () => _onNavBarItemTapped(index),
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1,
        duration: Duration(milliseconds: 200),
        child: Image.asset(
          isSelected ? activePath : iconPath,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
