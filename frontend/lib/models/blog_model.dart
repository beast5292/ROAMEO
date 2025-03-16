class Blog {
  final String id;
  final String userName;
  final String title;
  final String content;
  final String? imagePath;
  final int likes;
  final int dislikes;

  Blog({
    required this.id,
    required this.userName,
    required this.title,
    required this.content,
    this.imagePath,
    required this.likes,
    required this.dislikes,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imagePath: json['imagePath'],
      likes: (json['likes'] ?? 0).toInt(),
      dislikes: (json['dislikes'] ?? 0).toInt(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
