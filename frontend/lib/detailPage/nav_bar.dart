import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildNavIconWithImage(String iconPath, String activePath, int index) {
    bool isSelected = selectedIndex == index;
    double iconSize = (index == 2) ? 60 : 35; // AI icon larger size

    return GestureDetector(
      onTap: () => onItemTapped(index),
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