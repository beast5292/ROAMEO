import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/blog_model.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.5:8000";


  // Fetch all blogs
  static Future<List<Blog>> fetchBlogs() async {
    print("Fetching blogs from: $baseUrl/blogs"); // Debugging statement
    final response = await http.get(Uri.parse("$baseUrl/blogs"));
    print("Response status: ${response.statusCode}"); // Debugging statement
    print("Response body: ${response.body}"); // Debugging statement
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)["blogs"];
      return jsonList.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load blogs");
    }
  }

  // Update like/dislike count through the FastAPI backend
  static Future<void> updateLikeDislike(String blogId, String userId, bool isLike) async {
    final url = Uri.parse("$baseUrl/update-like-dislike/$blogId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "is_like": isLike
        }),
      );

      if (response.statusCode == 200) {
        print("Like/Dislike updated successfully: ${response.body}");
      } else {
        print("Failed to update Like/Dislike: ${response.body}");
      }
    } catch (e) {
      print("Error updating Like/Dislike: $e");
    }
  }






  // Create a new blog
  static Future<Map<String, dynamic>> createBlog(Map<String, dynamic> blog) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-blog"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(blog),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create blog");
    }
  }

  static Future<void> updateBlog(String blogId, Map<String, String> updatedBlog) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).update(updatedBlog);
    } catch (e) {
      print("Error updating blog: $e");
    }
  }
}
