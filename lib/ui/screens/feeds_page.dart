import 'package:flutter/material.dart';
import 'package:oratio_app/ui/widgets/feeds.dart';

class FeedsListScreen extends StatelessWidget {
  final List<Post> posts = [
    Post(
      author: 'User 1',
      content: 'This is the first post!',
      comments: ['Great post!', 'Thanks for sharing!'],
    ),
    Post(
      author: 'User 2',
      content: 'Hello, world!',
      comments: ['Hi there!', 'Nice to see you!'],
    ),
    // Add more posts as needed
  ];

  FeedsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeds'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(post: posts[index]);
        },
      ),
    );
  }
}
