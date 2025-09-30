import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:pocketbase/pocketbase.dart';

class PrayerCommentBottomSheet extends StatefulWidget {
  const PrayerCommentBottomSheet({
    super.key,
    required this.post,
  });
  final PrayerRequest post;

  @override
  _PrayerCommentBottomSheetState createState() =>
      _PrayerCommentBottomSheetState();
}

class _PrayerCommentBottomSheetState extends State<PrayerCommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool isComposing = false;
  int commentCount = 0;
  bool loading = false;
  bool error = false;
  List comments = [];
  bool searched = false;

  Future uploadComment(String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      await getComments(context);

      setState(() {
        // also upload to server
      });
      final newComment = await pb.collection('comments').create(body: {
        'user': (pb.authStore.model as RecordModel).id,
        'comment': comment,
      });

      pb.collection('prayer_requests').update(widget.post.id, body: {
        'comment+': [newComment.id]
      });
    } catch (e) {
      // display error on ui
      NotificationService.showError('Error occured uploading comment');
    }
  }

  Future<void> getComments(BuildContext context) async {
    ///fetch comments inside post
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final post = await pb
          .collection('prayer_requests')
          .getOne(widget.post.id, expand: 'comment,comment.user');
      if (post.expand.isEmpty) {
        return;
      }
      final results = post.expand['comment'] as List;
      commentCount = results.length;
      setState(() {
        comments = results;
      });
    } catch (e) {
      // display error on ui
      NotificationService.showError('error occured in getComments $e',
          duration: Durations.extralong1);
      error = true;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;

    if (comments.isEmpty && !searched) {
      getComments(context);
      searched = true;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${commentCount.toString()})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  comments.isEmpty
                      ? Container()
                      : Column(
                          children: comments.map((comment) {
                            return CommentItem(comment: comment as RecordModel);
                          }).toList(),
                        )
                ]),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: getProfilePic(context,
                              user: pb.authStore.model as RecordModel) ==
                          null
                      ? null
                      : CachedNetworkImageProvider(getProfilePic(context,
                          user: pb.authStore.model as RecordModel)!),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onChanged: (text) {},
                      decoration: InputDecoration(
                        hintText: commentCount == 0
                            ? 'Be the first to comment'
                            : 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            // Handle sending comment
                            uploadComment(_commentController.text.trim());
                            _commentController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({
    super.key,
    required this.post,
  });
  final Post post;

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool isComposing = false;
  int commentCount = 0;
  bool loading = false;
  bool error = false;
  List comments = [];
  bool searched = false;

  Future uploadComment(String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final recordModel = RecordModel(
          created: DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'")
              .format(DateTime.now().toUtc()),
          data: {
            'user':
                (pb.authStore.model as RecordModel).getStringValue('username'),
            'comment': comment,
          });

      setState(() {
        comments.add(recordModel);
        // also upload to server
      });
      final newComment = await pb.collection('comments').create(body: {
        'user': (pb.authStore.model as RecordModel).id,
        'comment': comment,
      });

      pb.collection('posts').update(widget.post.id, body: {
        'comment+': [newComment.id]
      });
    } catch (e) {
      // display error on ui
      NotificationService.showError('An error occured uploading comment');
    }
  }

  Future<void> getComments(BuildContext context) async {
    ///fetch comments inside post
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final post = await pb
          .collection('posts')
          .getOne(widget.post.id, expand: 'comment,comment.user');

      final results = post.expand['comment'] as List;
      commentCount = results.length;
      setState(() {
        comments = results;
      });
    } catch (e) {
      // display error on ui
      print('error occured in getComments $e');
      error = true;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty && !searched) {
      getComments(context);
      searched = true;
    }
    final pb = context.read<PocketBaseServiceCubit>().state.pb;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${commentCount.toString()})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  comments.isEmpty
                      ? Container()
                      : Column(
                          children: comments
                              .map((comment) =>
                                  CommentItem(comment: comment as RecordModel))
                              .toList(),
                        )
                ]),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: getProfilePic(context,
                              user: pb.authStore.model as RecordModel) ==
                          null
                      ? null
                      : CachedNetworkImageProvider(getProfilePic(context,
                          user: pb.authStore.model as RecordModel)!),
                  child: getProfilePic(context,
                              user: pb.authStore.model as RecordModel) ==
                          null
                      ? const Icon(FontAwesomeIcons.user)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onChanged: (text) {},
                      decoration: InputDecoration(
                        hintText: commentCount == 0
                            ? 'Be the first to comment'
                            : 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            // Handle sending comment
                            uploadComment(_commentController.text.trim());
                            _commentController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.comment,
  });
  final RecordModel comment;

  @override
  Widget build(BuildContext context) {
    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;
    final String? img = getProfilePic(context,
        user: comment.expand['user']?.first ?? RecordModel());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.expand['user']!.first.id == user.id) {
                //check if user is current user
                context.pushNamed(RouteNames.profile);
              } else {
                context.pushNamed(RouteNames.profilepagevisitor,
                    pathParameters: {'id': comment.expand['user']!.first.id});
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage:
                  img == null ? null : CachedNetworkImageProvider(img),
              child: img == null ? const Icon(FontAwesomeIcons.user) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (comment.expand['user']!.first.id == user.id) {
                          //check if user is current user
                          context.pushNamed(RouteNames.profile);
                        } else {
                          context.pushNamed(RouteNames.profilepagevisitor,
                              pathParameters: {
                                'id': comment.expand['user']!.first.id
                              });
                        }
                      },
                      child: Text(
                        comment.expand['user'] != null
                            ? comment.expand['user']![0]
                                .getStringValue('username')
                            : user.getStringValue('username'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatDateTimeToHoursAgo(
                          DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'")
                              .parse(comment.created)),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.getStringValue('comment'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     buildInteractionButton(
                //       icon: Icons.favorite_border,
                //       label: '${3}',
                //       onTap: () {},
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Usage Example
void showCommentSheet(BuildContext context, Post post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentBottomSheet(
      post: post,
    ),
  );
}

void showPrayerCommentSheet(BuildContext context, PrayerRequest post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PrayerCommentBottomSheet(
      post: post,
    ),
  );
}

Widget buildInteractionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Future<String?> showPrayerCommentOptions(BuildContext context) {
  final prayerOptions = [
    {
      'icon': FontAwesomeIcons.cross,
      'label': 'Station of the Cross',
      'value': 'Station of the Cross'
    },
    {'icon': FontAwesomeIcons.gem, 'label': 'Rosary', 'value': 'Rosary'},
    {
      'icon': FontAwesomeIcons.church,
      'label': 'Holy Mass',
      'value': 'Holy Mass'
    },
    {
      'icon': FontAwesomeIcons.handsPraying,
      'label': 'Ejaculatory',
      'value': 'Ejaculatory'
    },
    {
      'icon': FontAwesomeIcons.heart,
      'label': 'Hail Mary',
      'value': 'Hail Mary'
    },
    {
      'icon': FontAwesomeIcons.cloudSun,
      'label': 'Our Father',
      'value': 'Our Father'
    },
    {
      'icon': FontAwesomeIcons.dove,
      'label': 'Act of Contrition',
      'value': 'Act of Contrition'
    },
    {'icon': FontAwesomeIcons.star, 'label': 'Glory Be', 'value': 'Glory Be'},
    {'icon': FontAwesomeIcons.pen, 'label': 'Custom Prayer', 'value': 'custom'},
  ];

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Prayer Comment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(FontAwesomeIcons.xmark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prayerOptions
                        .map((option) => buildPrayerChip(
                              context,
                              icon: option['icon'] as IconData,
                              label: option['label'] as String,
                              onTap: () => Navigator.pop(
                                  context, option['value'] as String),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildPrayerChip(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
