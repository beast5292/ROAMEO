import 'package:flutter/material.dart';
import '../models/comment_model.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final int depth;

  const CommentWidget({Key? key, required this.comment, this.depth = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/cars1.png'),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 8),
              Text('${comment.timestamp.hour}:${comment.timestamp.minute}', style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          for (var reply in comment.replies) CommentWidget(comment: reply, depth: depth + 1),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }
}
