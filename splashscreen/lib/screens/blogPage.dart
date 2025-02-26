import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import 'create_blog_page.dart';
import 'notifications_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<Blog> blogs = [

  ];

  List<Blog> filteredBlogs = [];
  Map<int, int> likeCounts = {};
  Map<int, int> dislikeCounts = {};
  Map<int, String?> userActions = {}; // Track user actions (like/dislike)
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

  void _toggleLike(int index) {
    setState(() {
      if (userActions[index] == 'like') {
        likeCounts[index] = (likeCounts[index] ?? 0) - 1;
        userActions[index] = null;
      } else {
        if (userActions[index] == 'dislike') {
          dislikeCounts[index] = (dislikeCounts[index] ?? 0) - 1;
        }
        likeCounts[index] = (likeCounts[index] ?? 0) + 1;
        userActions[index] = 'like';
      }
    });
  }

  void _toggleDislike(int index) {
    setState(() {
      if (userActions[index] == 'dislike') {
        dislikeCounts[index] = (dislikeCounts[index] ?? 0) - 1;
        userActions[index] = null;
      } else {
        if (userActions[index] == 'like') {
          likeCounts[index] = (likeCounts[index] ?? 0) - 1;
        }
        dislikeCounts[index] = (dislikeCounts[index] ?? 0) + 1;
        userActions[index] = 'dislike';
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
              onPressed: () => setState(() {
                _isSearching = false;
                _searchController.clear();
                filteredBlogs = blogs;
              }),
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
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateBlogPage(
                            onSubmit: (Blog blog) {
                              setState(() {
                                blogs.add(blog);
                                filteredBlogs = blogs; // Update filteredBlogs list as well
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsPage()),
                      );
                    },
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: filteredBlogs.isEmpty
          ? Center(child: Text('No blogs available', style: TextStyle(color: Colors.white)))
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
                      Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(blog.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.imagePath != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(blog.imagePath!, height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                      Text(blog.content, style: TextStyle(color: Colors.white, fontSize: 15)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward, color: userActions[index] == 'like' ? Colors.green : Colors.white),
                            onPressed: () => _toggleLike(index),
                          ),
                          Text('${likeCounts[index] ?? 0}', style: TextStyle(color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.arrow_downward, color: userActions[index] == 'dislike' ? Colors.red : Colors.white),
                            onPressed: () => _toggleDislike(index),
                          ),
                          Text('${dislikeCounts[index] ?? 0}', style: TextStyle(color: Colors.white)),
                          IconButton(icon: Icon(Icons.message_outlined, color: Colors.white), onPressed: () {}),
                          Spacer(),
                          IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {}),
                        ],
                      ),
                      Divider(color: Colors.white24, thickness: 1),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
