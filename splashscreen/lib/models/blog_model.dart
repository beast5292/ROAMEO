import 'dart:io';

class Blog {
  final String title;
  final String content;
  final String? imagePath;
  //final File? image;

  Blog({
    required this.title,
    required this.content,
    this.imagePath,
    //this.image,
  });
}
