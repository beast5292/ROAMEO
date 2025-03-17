class Comment {
  String author;
  String content;
  DateTime timestamp;
  List<Comment> replies; // Nested comments

  Comment({
    required this.author,
    required this.content,
    required this.timestamp,
    this.replies = const [],
  });
}
