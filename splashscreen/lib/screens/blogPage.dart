import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import 'comments_page.dart';
import 'create_blog_page.dart';
import 'notifications_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<Blog> blogs = [];
  List<Blog> filteredBlogs = [];

  // Firestore stream to fetch blogs
  Stream<List<Blog>> getBlogs() {
    return FirebaseFirestore.instance.collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Blog.fromFirestore(doc)).toList();
    });
  }


  // Function to filter blogs based on the search query
  void _filterBlogs() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredBlogs = blogs.where((blog) {
        return blog.title.toLowerCase().contains(query) ||
            blog.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBlogs);
    filteredBlogs = blogs;
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
                                  blogs.add(blog); // Add the new blog
                                  filteredBlogs = blogs; // Update filteredBlogs as well
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
        body: StreamBuilder<List<Blog>>(
            stream: getBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No blogs available', style: TextStyle(color: Colors.white)));
              }

              List<Blog> blogs = snapshot.data!;
              return ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogs[index];
                  return _buildBlogCard(blog); // Display each blog
                },
              );
            }
        )

    );
  }


  // Function to show comments for a specific blog
  void _showComments(String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(blogId: blogId), // Pass blogId here
      ),
    );
  }
}
