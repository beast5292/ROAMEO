import 'package:flutter/material.dart';

class blogPage extends StatelessWidget {
  const blogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Text
            const SizedBox(width: 0.5),
            const Text('ROMEO',
              style: TextStyle(color: Colors.white),),
            const Spacer(), // Pushes the next widgets to the right
            // Search icon
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 28,),
              onPressed: () {
                // Add search functionality here
              },
            ),
            // Circular image on the right
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/cars5.png'),
              // Add your image asset
              radius: 16,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      backgroundColor: Colors.black,
      // Sidebar (Drawer)
      drawer: SizedBox(
        width: 260,

        child: Drawer(


          child: Container(
            color: Colors.black,

            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                SizedBox(height: 40),
                const Divider(color: Colors.white24,),
                // First Header Section
                ListTile(
                  title: const Text(
                    'Recently Visited',
                    style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),

                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/Cars',
                    style: TextStyle(fontSize: 14, color: Colors.white),),

                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Home
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/Music',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Profile
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/Cricket',
                      style: TextStyle(fontSize: 14, color: Colors.white,)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Settings
                  },
                ),
                // Second Header Section
                const Divider(color: Colors.white24,),
                ListTile(
                  title: const Text(
                    'Your Communities',
                    style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/StockMarket',
                      style: TextStyle(fontSize: 14, color: Colors.white,)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Notifications
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/Bitcoin',
                      style: TextStyle(fontSize: 14, color: Colors.white,)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Help
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.circle_outlined, color: Colors.white, size: 22,),
                  title: const Text('r/formula1',
                      style: TextStyle(fontSize: 14, color: Colors.white,)),
                  onTap: () {
                    Navigator.pop(context);
                    // Log out
                  },
                ),
                const Divider(color: Colors.white24,),
                ListTile(
                  leading: const Icon(
                    Icons.blur_circular_outlined, color: Colors.white,
                    size: 22,),
                  title: const Text('All',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Help
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
