import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import 'create_blog_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  int _selectedIndex = 0;

  List<Blog> blogs = [
    Blog(
      title: "Helloooooooooo oooohhhh",
      content: "ahhhhh jcndwbcewkcw cwkanlifkv ef evken hevc bvcjksnvks,b jhebfrv euvbejbvuv",
      imagePath: ('lib/assets/images/cars5.png'),
    ),

    Blog(
      title: "heeeeee heeeeeee",
      content: "ahhhhh jcndwbcewkcw cwkanlifkv ef evken hevc bvcjksnvks,b jhebfrv euvbejbvuv",
      imagePath: ('lib/assets/images/cars1.jpg'),
    ),

    Blog(
      title: "content without image",
      content: "ahhhhh jcndwbcewkcw cwkanlifkv ef evken hevc bvcjksnvks,b jhebfrv euvbejbvuv",

    ),
    Blog(
      title: "hoooooooooooo oooooooooooh",
      content: "ahhhhh jcndwbcewkcw cwkanlifkv ef evken hevc bvcjksnvks,b jhebfrv euvbejbvuv",
      imagePath: ('lib/assets/images/Logo.png'),
    ),
  ]; // Declare the blogs list




  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Navigation icon $index tapped");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/images/Logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10), // Small spacing between logo and title/icons
            Expanded( // Key change: Use Expanded
              child: Row( // Row for the icons and avatar
                mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                    onPressed: () {
                      // Add search functionality here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateBlogPage(
                              onSubmit: (Blog blog) {},
                            )),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/images/cars5.png'),
                    radius: 16,
                  ),
                ],
              ),

            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white
          // ... rest of your AppBar code
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
/*
      body: blogs.isEmpty
          ? Center(child: Text('No blogs available', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))
          : ListView.builder(
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text(blog.title, style: TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 if (blog.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                        child: Image.asset(
                          blog.imagePath!,
                          height: 200,
                          width: 500,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Text(blog.content, style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
          );
        },
      ),

 */
      body: blogs.isEmpty
          ? Center(child: Text('No blogs available', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Card(
            color: Colors.black,
            child: ListTile(
              title: Text(blog.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (blog.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                        child: Image.asset(
                          blog.imagePath!,
                          height: 200,
                          width: 500,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Text(blog.content, style: TextStyle(color: Colors.white, fontSize: 15)),

                  // Divider (line at the end of the card)
                  Divider(
                    color: Colors.white24, // Line color
                    thickness: 1, // Line thickness
                  ),
                ],
              ),
            ),
          );
        },
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
                  'lib/assets/icons/Icon1onclick.png', 'lib/assets/icons/icon1.png', 0),
              _buildNavIconWithImage(
                  'lib/assets/icons/icon2.png', 'lib/assets/icons/icon2.png', 1),
              _buildNavIconWithImage(
                  'lib/assets/icons/aiicon.png', 'lib/assets/icons/aiicon.png', 2),
              _buildNavIconWithImage('lib/assets/icons/exploreicon.png',
                  'lib/assets/icons/exploreonclick.png', 3),
              _buildNavIconWithImage('lib/assets/icons/feedicon.png',
                  'lib/assets/icons/feedonclick.png', 4),
            ],
          ),
        ),
      ),
    );
  }
}

