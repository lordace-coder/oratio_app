import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:pocketbase/pocketbase.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _loading = false;
  RecordModel? data;
  bool error = false;

  String? getAvatarUrl(BuildContext context,
      {required RecordModel record, required String fileName}) {
    final pb = getPocketBaseFromContext(context);

    try {
      final url = pb.getFileUrl(record, fileName).toString();
      if (url.isNotEmpty) {
        return url;
      }
    } catch (e) {
      print('error fetching avatar $e');
    }
    return null;
  }

  void handleGetPosts() async {
    setState(() {
      error = false;
      _loading = true;
    });
    try {
      final res = await getPost(context, postId: widget.postId);
      setState(() {
        data = res;
        _loading = false;
      });
      return;
    } catch (e) {
      NotificationService.showError('Error occured getting post');
      setState(() {
        error = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleGetPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Builder(builder: (context) {
        if (_loading) {
          return Container(
            child: Lottie.asset('assets/lottie/anim1.json'),
          );
        }

        final avatarUrl = getAvatarUrl(context,
            record: data!.expand['community']!.first,
            fileName: data!.expand['community']!.first.getStringValue('image'));
        return CustomScrollView(
          slivers: [
            // Elegant app bar with blur effect
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              backgroundColor: Colors.white.withOpacity(0.8),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: avatarUrl != null
                                ? null
                                : Icon(FontAwesomeIcons.church,
                                    color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // '${data!.author.getStringValue('first_name')} ${data!.author.getStringValue('last_name')}',
                                  data!.expand['community']!.first
                                      .getStringValue('community'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  // data!.date,
                                  data!.created,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // snapshot!.data content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        // data!.post,
                        data!.getStringValue('post'),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Action buttons
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildActionButton(Icons.favorite_border, 'Like'),
                          _buildActionButton(
                              Icons.chat_bubble_outline, 'Comment'),
                          _buildActionButton(Icons.share_outlined, 'Share'),
                        ],
                      ),
                    ),

                    // Comments section
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget _buildActionButton(IconData icon, String label) {
  return Expanded(
    child: TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[700], size: 20),
      label: Text(
        label,
        style: TextStyle(color: Colors.grey[700]),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    ),
  );
}
