import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _selectedIndex = 3; // Default active tab
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.72); //adjust width of travel card

  final List<Map<String, dynamic>> travelCards = [
    {"name": "Galle", "image": "assets/images/Galle.png", "rating": 4.6},
    {"name": "Hambanthota", "image": "assets/images/Hambanthota.png", "rating": 4.2},
    {"name": "Dambulla", "image": "assets/images/Dambulla.png", "rating": 4.5},
    {"name": "Ella", "image": "assets/images/Ella.png", "rating": 4.7},
    {"name": "Kandy", "image": "assets/images/Kandy.jpg", "rating": 5.0},
    {"name": "Anuradhapura", "image": "assets/images/Anuradhapura.jpg", "rating": 4.4},
    {"name": "Mirissa", "image": "assets/images/Mirissa.jpg", "rating": 4.9},
    {"name": "Nuwara Eliya", "image": "assets/images/Nuwaraeliya.jpg", "rating": 4.5},
    {"name": "Trincomalee", "image": "assets/images/Trinco.jpg", "rating": 4.3},
    {"name": "Colombo", "image": "assets/images/Colombo.jpg", "rating": 4.1},
    {"name": "Jaffna", "image": "assets/images/Jaffna.jpg", "rating": 4.0},
    {"name": "Udawalawe", "image": "assets/images/Udawalawe.jpg", "rating": 4.6},
  ];

  List<Map<String, dynamic>> _filteredTravelCards = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTravelCards = List.from(travelCards); // Initialize with all cards
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _filterTravelCards(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all travel cards
        _filteredTravelCards = List.from(travelCards);
      } else {
        // Filter the travel cards based on the query
        _filteredTravelCards = travelCards
            .where((card) =>
                card["name"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //Ensure the screen resizes when the keyboard appears
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView( //Make the screen scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              //Back Button & Search Bar 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Row(
                  children: [
                    //Back Button 
                    GestureDetector(
                      onTap: () {
                        print("Back button tapped");
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center( 
                          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    //Search Bar 
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.search, color: Colors.white, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search...",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                onChanged: (query) {
                                  // Call a method to filter the travel cards
                                  _filterTravelCards(query);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Category Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCategoryChip("Booking"),
                    const SizedBox(width: 10),
                    _buildCategoryChip("Recommendations"),
                  ],
                ),
              ),

              //Travel Cards with PageView
              const SizedBox(height: 40),
              SizedBox(
                height: 451, //adjust travel card height
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _filteredTravelCards.length, // Use filtered list
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final travel = _filteredTravelCards[index]; // Use filtered list
                    final isSelected = index == _currentPage;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isSelected ? 1.0 : 0.5,
                      child: TravelCard(
                        name: travel["name"],
                        imagePath: travel["image"],
                        rating: travel["rating"],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),

      //Bottom Navigation Bar 
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 26.0),
        child: Container(
          height: 60,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIconWithImage('assets/icons/homeicon.png', 'assets/icons/homeonclick.png', 0),
              _buildNavIconWithImage('assets/icons/chaticon.png', 'assets/icons/chaticon.png', 1),
              _buildNavIconWithImage('assets/icons/aiicon.png', 'assets/icons/aiicon.png', 2),
              _buildNavIconWithImage('assets/icons/exploreicon.png', 'assets/icons/exploreonclick.png', 3),
              _buildNavIconWithImage('assets/icons/feedicon.png', 'assets/icons/feedonclick.png', 4),
            ],
          ),
        ),
      ),
    );
  }

  //Category Chip Widget
  Widget _buildCategoryChip(String text) {
    return GestureDetector(
      onTap: () => print("$text tapped"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //Bottom Navigation Bar Icon Widget
  Widget _buildNavIconWithImage(String iconPath, String activePath, int index) {
    bool isSelected = _selectedIndex == index;
    double iconSize = (index == 2) ? 60 : 35; // AI icon larger size

    return GestureDetector(
      onTap: () => _onNavBarItemTapped(index),
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Image.asset(
          isSelected ? activePath : iconPath,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}

//TravelCard Component
class TravelCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final double rating;
  final bool isSelected;
  final VoidCallback onTap;

  const TravelCard({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 220, 
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Positioned(top: 25, left: 25, child: _buildRatingBadge(rating)),
            Positioned(top: 25, right: 25, child: Icon(Icons.bookmark, color: Colors.white, size: 30)),
            Positioned(bottom: 25, left: 25, child: _buildNameLabel(name)),
            Positioned(bottom: 25, right: 25, child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) => Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)), child: Text("$rating ⭐", style: const TextStyle(color: Colors.black)));

  Widget _buildNameLabel(String name) => Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
}