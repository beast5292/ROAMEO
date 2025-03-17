import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final String blogId;  // ID of the blog post for which comments are to be displayed

  CommentsPage({required this.blogId});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  // Fetch comments from Firestore
  Future<void> _fetchComments() async {
    try {
      final commentSnapshot = await FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blogId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _comments = commentSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  // Add a new comment to Firestore
  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        final comment = {
          'userName': 'User', // Replace with actual user name
          'content': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        print("Adding comment: $comment"); // Debugging statement

        await FirebaseFirestore.instance
            .collection('blogs')
            .doc(widget.blogId)
            .collection('comments')
            .add(comment);

        // Clear the text field
        _commentController.clear();

        // Fetch the comments again to update the list
        _fetchComments();  // This will reload the comments list and update the UI
      } catch (e) {
        print("Error adding comment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Card(
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['userName'],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          comment['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
