import 'dart:io';
import 'package:bloge/screens/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../services/api_service.dart';
import 'FullScreenImagePage.dart';
import 'comments_page.dart';
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
  Map<String, bool?> userReactions = {}; // Stores user's reaction per blog (true = like, false = dislike, null = no reaction)

  // Declare the lists here
  List<Blog> blogs = [];
  List<Blog> filteredBlogs = [];

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    print("Fetching blogs..."); // Debugging statement
    try {
      final List<Blog> fetchedBlogs = await ApiService.fetchBlogs();
      print("Fetched blogs: $fetchedBlogs"); // Debugging statement
      setState(() {
        blogs = fetchedBlogs;
        filteredBlogs = blogs;
      });
    } catch (e) {
      print("Error fetching blogs: $e"); // Debugging statement
    }
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

  Future<void> _updateLikeDislikeCount(String blogId, bool isLike) async {
    String userId = "123"; // Replace with actual user ID from authentication system

    if (userReactions.containsKey(blogId) && userReactions[blogId] == isLike) {
      print("User has already reacted this way. Ignoring request.");
      return; // Stop the user from liking/disliking multiple times.
    }

    try {
      await ApiService.updateLikeDislike(blogId, userId, isLike);

      setState(() {
        final index = blogs.indexWhere((blog) => blog.id == blogId);
        if (index != -1) {
          if (isLike) {
            blogs[index] = Blog(
              id: blogs[index].id,
              userName: blogs[index].userName,
              title: blogs[index].title,
              content: blogs[index].content,
              imagePath: blogs[index].imagePath,
              likes: blogs[index].likes + 1,
              dislikes: blogs[index].dislikes - (userReactions[blogId] == false ? 1 : 0),
            );
          } else {
            blogs[index] = Blog(
              id: blogs[index].id,
              userName: blogs[index].userName,
              title: blogs[index].title,
              content: blogs[index].content,
              imagePath: blogs[index].imagePath,
              likes: blogs[index].likes - (userReactions[blogId] == true ? 1 : 0),
              dislikes: blogs[index].dislikes + 1,
            );
          }
        }
        filteredBlogs = List.from(blogs);

        // Update user reaction state
        userReactions[blogId] = isLike;
      });

    } catch (e) {
      print("Error updating like/dislike count: $e");
    }
  }




  // Fetch comments for a specific blog post
  Future<void> _fetchComments(String blogId) async {
    try {
      final commentSnapshot = await FirebaseFirestore.instance
          .collection('blogs')
          .doc(blogId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      // Fetch the comments data
      final comments = commentSnapshot.docs.map((doc) => doc.data()).toList();

      // Optionally, you can update your UI with the comments list.
      // This part depends on how you want to display them under each blog post.
      print("Comments for blog $blogId: $comments");
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  // Add a comment to Firestore
  Future<void> _addComment(String blogId, String commentText) async {
    if (commentText.isNotEmpty) {
      try {
        final commentData = {
          'userName': 'User', // Replace with actual user name
          'content': commentText,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('blogs')
            .doc(blogId)
            .collection('comments')
            .add(commentData);

        // Refresh the comments after adding
        _fetchComments(blogId);
      } catch (e) {
        print("Error adding comment: $e");
      }
    }
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
                onChanged: (value) => _filterBlogs(),
              ),
            ),
          ],
        )
            : Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {}); // Refresh the page
              },
              child: Image.asset(
                'lib/assets/images/Logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _isSearching = true),
            ),
            IconButton(
              icon: Icon(Icons.add_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBlogPage(
                      onSubmit: (Map<String, String> blog) {
                        setState(() {
                          blogs.add(Blog.fromJson(blog));
                          filteredBlogs = blogs;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(numberOfPosts: filteredBlogs.length), // Pass the number of posts here
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/cars5.png'),
                radius: 16,
              ),
            ),


          ],
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: filteredBlogs.length,
        itemBuilder: (context, index) {
          final blog = filteredBlogs[index];
          return _buildBlogCard(blog);
        },
      ),
    );
  }

  Widget _buildBlogCard(Blog blog) {
    return Card(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/images/cars5.png'),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Text(blog.userName,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            title: Text(blog.title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog.imagePath != null && blog.imagePath!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to full-screen image page when the image is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(imagePath: blog.imagePath!),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(blog.imagePath!),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                Text(blog.content, style: TextStyle(color: Colors.white, fontSize: 15)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        color:Colors.white,
                      ),
                      onPressed: () => _updateLikeDislikeCount(blog.id, true),
                    ),
                    Text(blog.likes.toString(),style: TextStyle(color: Colors.white),),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                          color:Colors.white
                      ),
                      onPressed: () => _updateLikeDislikeCount(blog.id, false),
                    ),

                    Text(blog.dislikes.toString(), style: TextStyle(color: Colors.white)),
                    IconButton(
                      icon: Icon(Icons.message_outlined, color: Colors.white),
                      onPressed: () => _showComments(blog.id),
                    ),
                    Spacer(),
                    
                  ],
                ),
                Divider(color: Colors.white24, thickness: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }




  void _showComments(String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(blogId: blogId),
      ),
    );
  }
}
