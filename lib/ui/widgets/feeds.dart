import 'package:flutter/material.dart';

class Post {
  final String author;
  final String content;
  final List<String> comments;

  Post({required this.author, required this.content, required this.comments});
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.author,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(post.content),
            const SizedBox(height: 10),
            const Text('Comments:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...post.comments.map((comment) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('• $comment'),
                )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Add comment functionality
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add Comment'),
                      content: const TextField(
                        decoration:
                            InputDecoration(hintText: 'Type your comment here'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Add Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
