import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:pocketbase/pocketbase.dart';

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key, required this.post});
  final Post post;

  Future uploadComment(BuildContext context, String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      await pb.collection('comments').create(body: {
        'comment': comment,
        'user': (pb.authStore.model as RecordModel).id
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                'SC',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              post.community!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(post.date),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              post.post,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Post Image
          if (post.image!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 9),
              height: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  image: DecorationImage(image: NetworkImage(post.image!))),
            ),
          // Post Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PostAction(
                  icon: !post.likes.contains(user.id)
                      ? Icons.favorite_border
                      : Icons.favorite,
                  label: post.likes.length.toString(),
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _PostAction(
                  icon: Icons.comment_outlined,
                  label: post.commentCount.length.toString(),
                  onTap: () {
                    print(post.commentCount);
                    showCommentSheet(context, post);
                  },
                ),
                const SizedBox(width: 24),
                _PostAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerRequestCard extends StatelessWidget {
  const PrayerRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer Request Header
          ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Text(
                'JD',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: const Text(
              'John Doe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('1 hour ago', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 8),
                Icon(Icons.public, size: 14, color: Colors.grey[600]),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text('Report')),
                const PopupMenuItem(child: Text('Share')),
              ],
            ),
          ),
          // Prayer Request Content
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Urgent Prayer Request',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please pray for my mother who is undergoing surgery tomorrow morning. 🙏',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Prayer Actions
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _PrayerAction(
                  icon: Icons.favorite_border,
                  label: 'Praying (42)',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _PrayerAction(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: icon != Icons.favorite ? Colors.grey[600] : Colors.red),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _PrayerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrayerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5)),
        ),
      ),
    );
  }
}
