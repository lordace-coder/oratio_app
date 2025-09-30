import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/widgets/image_viewer.dart';
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
  bool _isExpanded = false;
  static const int _maxLines = 3;
  bool _shouldShowMoreButton = false;
  int commentCount = 0;
  List comments = [];
  bool searched = false;
  bool loading = false;
  bool? hasLiked;
  final _commentController = TextEditingController();

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
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final postHelper = PostHelper(pb);
      final res = await postHelper.getPost(
        widget.postId,
      );
      setState(() {
        data = res;
        _loading = false;
      });
      _calculateTextHeight(); // Recalculate text height when data is fetched
      return;
    } catch (e) {
      print(e);
      NotificationService.showError('Error occurred getting post');
      setState(() {
        error = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void _calculateTextHeight() {
    if (!mounted || data == null) return;

    final textSpan = TextSpan(
      text: data!.getStringValue('post'),
      style: const TextStyle(fontSize: 16, height: 1.5),
    );

    const TextDirection dir = TextDirection.ltr;
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: dir,
      maxLines: _maxLines,
    );

    final constraintWidth =
        MediaQuery.of(context).size.width - 32; // Account for padding
    textPainter.layout(maxWidth: constraintWidth);

    if (mounted) {
      setState(() {
        _shouldShowMoreButton = textPainter.didExceedMaxLines;
      });
    }
  }

  String getDate(RecordModel record) {
    intl.DateFormat format = intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");

    return formatDateTimeToHoursAgo(format.parse(record.created));
  }

  Future uploadComment(String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final recordModel = RecordModel(
          created: intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'")
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

      if (data != null) {
        pb.collection('posts').update(data!.id, body: {
          'comment+': [newComment.id]
        });
      }
    } catch (e) {
      // display error on ui
      print(e);

      NotificationService.showError('An error occurred uploading comment');
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
          .getOne(data!.id, expand: 'comment,comment.user');

      final results = post.expand['comment'] as List;
      commentCount = results.length;
      setState(() {
        comments = results;
      });
    } catch (e) {
      // display error on ui
      print(e);

      print('error occurred in getComments $e');
      error = true;
    }

    setState(() {
      loading = false;
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
  void didUpdateWidget(PostDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateTextHeight();
  }

  @override
  Widget build(BuildContext context) {
    print(1);
    if (_loading && data == null) {
      return Scaffold(
        body: Container(
          child: Lottie.asset('assets/lottie/anim1.json'),
        ),
      );
    }
    if (data == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error loading post'),
        ),
      );
    }
    final userId =
        context.read<PocketBaseServiceCubit>().state.pb.authStore.model.id;
    hasLiked ??= (data!.getListValue('likes')).contains(userId);

    final community = data!.expand['community']?.first;
    final avatarUrl = community != null
        ? getAvatarUrl(
            context,
            record: community,
            fileName: community.getStringValue('image'),
          )
        : null;

    if (comments.isEmpty && !searched) {
      getComments(context);
      searched = true;
    }
    final pb = getPocketBaseFromContext(context);
    print([community, 'ss']);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // App Bar
          PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  backgroundColor: Colors.grey[100],
                  elevation: 0,
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    '${community?.getStringValue('community') ?? ''}\'s Post',
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  centerTitle: true,
                ),
              ),
            ),
          ),

          // Main Content - Scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Section
                    GestureDetector(
                      onTap: () {
                        try {
                          if (community != null) {
                            openCommunity(context, community.id);
                          }
                        } catch (e) {
                          print(e);

                          NotificationService.showError('Something went wrong');
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: avatarUrl != null
                                ? CachedNetworkImageProvider(avatarUrl)
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
                                  community?.getStringValue('community') ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  getDate(data!),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Post Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data!.getStringValue('post'),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            maxLines: _isExpanded ? null : _maxLines,
                            overflow: _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (_shouldShowMoreButton)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _isExpanded ? 'See less' : 'See more',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Post Image
                    if (data!.getStringValue('image').isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          openImageView(
                            context,
                            getAvatarUrl(
                              context,
                              record: data!,
                              fileName: data!.getStringValue('image'),
                            )!,
                            imageUrl: getAvatarUrl(
                              context,
                              record: data!,
                              fileName: data!.getStringValue('image'),
                            )!,
                          );
                        },
                        onLongPress: () async {
                          var save = await confirm(
                            context,
                            content:
                                const Text('Do you want to save this image?'),
                          );
                          if (save) {
                            FileDownloadHandler.downloadRawFile(
                              context,
                              getAvatarUrl(
                                context,
                                record: data!,
                                fileName: data!.getStringValue('image'),
                              )!,
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 9,
                          ),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                getAvatarUrl(
                                  context,
                                  record: data!,
                                  fileName: data!.getStringValue('image'),
                                )!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                    // Engagement Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            (data!.getListValue('likes')).length == 1
                                ? '${(data!.getListValue('likes')).length} like'
                                : '${(data!.getListValue('likes')).length} likes',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            commentCount == 1
                                ? '$commentCount comment'
                                : '$commentCount comments',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10), // Action Buttons
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: _PostAction(
                              icon: !hasLiked!
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              label: '${(data!.getListValue('likes')).length}',
                              onTap: () async {
                                final pb = context
                                    .read<PocketBaseServiceCubit>()
                                    .state
                                    .pb;
                                final postHelper = PostHelper(pb);
                                if (hasLiked!) {
                                  // unlike the post
                                  await postHelper.dislikePost(data!.id);
                                  (data!.getListValue('likes'))
                                      .remove(data!.id);
                                } else {
                                  await postHelper.likePost(data!.id);
                                  (data!.getListValue('likes')).add(data!.id);
                                }
                                setState(() {
                                  hasLiked = !hasLiked!;
                                });
                              },
                            ),
                          ),
                          _PostAction(
                            icon: Icons.comment,
                            label: '$commentCount',
                            onTap: () async {
                              try {} catch (e) {}
                            },
                          ),
                        ],
                      ),
                    ),

                    // Comments Section
                    if (!searched || loading)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 20, 9, 45),
                          ),
                        ),
                      ),
                    if (comments.isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(child: Text('No comments ')),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments
                            .map((comment) =>
                                CommentItem(comment: comment as RecordModel))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Comment Input Section - Fixed at bottom
          Container(
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
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CircleAvatar(
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
          Icon(
            icon,
            size: 20,
            color: icon != Icons.favorite ? Colors.grey[600] : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
