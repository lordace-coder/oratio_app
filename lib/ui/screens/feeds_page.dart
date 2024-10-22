import 'package:flutter/material.dart';
import 'package:oratio_app/ui/widgets/feeds.dart';

class FeedsListScreen extends StatelessWidget {
  const FeedsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeds'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return const UpdateItem();
        },
      ),
    );
  }
}
