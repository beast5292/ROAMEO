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
  bool _isSearching = false; // Track if search is active
  TextEditingController _searchController = TextEditingController();
  List<Blog> blogs = [
    
    
  ];

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

  List<Blog> filteredBlogs = []; // Stores filtered blogs
  Map<int, int> likeCounts = {};
  Map<int, int> dislikeCounts = {};
  String userName = "User Name";
  String userProfileImage = 'lib/assets/images/cars5.png';

  @override
  void initState() {
    super.initState();
    filteredBlogs = blogs;
    _searchController.addListener(_filterBlogs);
  }

  void _filterBlogs() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredBlogs = blogs.where((blog) {
        return blog.title.toLowerCase().contains(query) ||
            blog.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        filteredBlogs = blogs;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _toggleSearch,
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search blogs...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )


            : Row(
          children: [
            Image.asset(
              'lib/assets/images/Logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search,
                        color: Colors.white, size: 28),
                    onPressed: _toggleSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 28),
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
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    backgroundImage:
                    AssetImage('lib/assets/images/cars5.png'),
                    radius: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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


      backgroundColor: Colors.black,
      body: filteredBlogs.isEmpty
          ? Center(
        child: Text(
          'No blogs available',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: filteredBlogs.length,
        itemBuilder: (context, index) {
          final blog = filteredBlogs[index];
          return Card(
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(userProfileImage),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(blog.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              blog.imagePath!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Text(blog.content,
                          style: TextStyle(
                              color: Colors.white, fontSize: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                likeCounts[index] =
                                    (likeCounts[index] ?? 0) + 1;
                              });
                            },
                          ),
                          Text('${likeCounts[index] ?? 0}',
                              style: TextStyle(color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.arrow_downward,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                dislikeCounts[index] =
                                    (dislikeCounts[index] ?? 0) + 1;
                              });
                            },
                          ),
                          Text('${dislikeCounts[index] ?? 0}',
                              style: TextStyle(color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.message_outlined,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 100),
                          IconButton(
                            icon:
                            const Icon(Icons.share, color: Colors.white),
                            onPressed: () {},
                          ),

                        ],
                      ),
                      // Divider (line at the end of the card)
                      Divider(
                        color: Colors.white24, // Line color
                        thickness: 1, // Line thickness
                      ),
                    ],
                  ),
                ),
              ],
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
