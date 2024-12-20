import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/image_viewer.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:pocketbase/pocketbase.dart';

class CommunityPostCard extends StatefulWidget {
  const CommunityPostCard({super.key, required this.post});
  final Post post;

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool? hasLiked;
  bool _isExpanded = false;
  static const int _maxLines = 3;
  bool _shouldShowMoreButton = false;

  @override
  void initState() {
    super.initState();
    // Schedule the calculation for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextHeight();
    });
  }

  void _calculateTextHeight() {
    if (!mounted) return;

    final textSpan = TextSpan(
      text: widget.post.post,
      style: Theme.of(context).textTheme.bodyLarge,
    );

    const TextDirection dir = TextDirection.ltr;
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: dir,
      maxLines: _maxLines,
    );

    final constraintWidth =
        MediaQuery.of(context).size.width - 40; // Account for padding
    textPainter.layout(maxWidth: constraintWidth);

    if (mounted) {
      setState(() {
        _shouldShowMoreButton = textPainter.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;

    hasLiked ??= widget.post.likes.contains(user.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            onTap: () {
              try {
                openCommunity(context, widget.post.communityId!);
              } catch (e) {
                NotificationService.showError('Something went wrong');
              }
            },
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: widget.post.getAvatar(context) != null
                  ? NetworkImage(widget.post.getAvatar(context)!)
                  : null,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: widget.post.getAvatar(context) != null
                  ? null
                  : Icon(FontAwesomeIcons.church,
                      color: Theme.of(context).primaryColor),
            ),
            title: Text(
              widget.post.community!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.post.date),
          ),
          // Post Content with See More
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.post,
                  style: Theme.of(context).textTheme.bodyLarge,
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
          if (widget.post.image!.isNotEmpty)
            GestureDetector(
              onTap: () {
                openImageView(context, imageUrl: widget.post.image);
              },
              onLongPress: () async {
                var save = await confirm(context,
                    content: const Text('Do you want to save this image?'));
                if (save) {
                  FileDownloadHandler.downloadRawFile(widget.post.image!);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 9),
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    image: DecorationImage(
                      image: NetworkImage(widget.post.image!),
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          // Post Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PostAction(
                  icon: !hasLiked! ? Icons.favorite_border : Icons.favorite,
                  label: widget.post.likes.length.toString(),
                  onTap: () async {
                    if (hasLiked!) {
                      // unlike the post
                      context.read<PostCubit>().dislikePost(
                            widget.post.id,
                          );
                      widget.post.likes.remove(user.id);
                    } else {
                      context.read<PostCubit>().likePost(
                            widget.post.id,
                          );
                      widget.post.likes.add(user.id);
                    }
                    setState(() {
                      hasLiked = !hasLiked!;
                    });
                  },
                ),
                const SizedBox(width: 24),
                _PostAction(
                  icon: Icons.comment_outlined,
                  label: widget.post.commentCount.length.toString(),
                  onTap: () {
                    showCommentSheet(context, widget.post);
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

class PrayerRequestCard extends StatefulWidget {
  const PrayerRequestCard({super.key, required this.data});

  final PrayerRequest data;

  @override
  State<PrayerRequestCard> createState() => _PrayerRequestCardState();
}

class _PrayerRequestCardState extends State<PrayerRequestCard> {
  bool? isPraying;
  int isPrayingCount = 0;
  intl.DateFormat format = intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  late PocketBase pb;
  PrayerRequest? _prayerRequest;

  Future addPraying(BuildContext context) async {
    final bool praying = widget.data.praying.contains(pb.authStore.model.id);
    try {
      setState(() {
        isPraying = !isPraying!;
        if (praying) {
          isPrayingCount--;
        } else {
          isPrayingCount++;
        }
      });
      if (praying) {
        await pb.collection('prayer_requests').update(widget.data.id, body: {
          'praying-': [pb.authStore.model.id]
        });

        _prayerRequest?.praying.remove(pb.authStore.model.id);

        NotificationService.showWarning('You removed your prayer',
            duration: Durations.extralong4);
      } else {
        await pb.collection('prayer_requests').update(widget.data.id, body: {
          'praying+': [pb.authStore.model.id]
        });
        _prayerRequest?.praying.add(pb.authStore.model.id);

        NotificationService.showSuccess('Prayer said succesfully',
            duration: Durations.extralong4);
      }
    } catch (e) {
      // display error on ui
      NotificationService.showError('error occured while sending prayer');
    }
  }

  Future uploadComment(BuildContext context, String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final newComment = await pb.collection('comments').create(body: {
        'user': (pb.authStore.model as RecordModel).id,
        'comment': comment,
      });

      pb.collection('prayer_requests').update(widget.data.id, body: {
        'comment+': [newComment.id]
      });
    } catch (e) {
      // display error on ui
      print('error occured in getComments $e');
    }
  }

  String formatCount(int number) {
    if (number < 1000) return number.toString();

    if (number < 1000000) {
      double result = number / 1000;
      // Show one decimal place if number is not exactly divisible by 1000
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K';
    }

    if (number < 1000000000) {
      double result = number / 1000000;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M';
    }

    double result = number / 1000000000;
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}B';
  }

  @override
  void initState() {
    super.initState();
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    isPrayingCount = widget.data.praying.length;
    isPraying = widget.data.praying.contains(pb.authStore.model.id);
  }

  @override
  Widget build(BuildContext context) {
    _prayerRequest ??= widget.data;
    if (isPrayingCount <= 0) {
      isPrayingCount = 0;
    }
    final pb = context.read<PocketBaseServiceCubit>().state.pb;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer Request Header
          ListTile(
            onTap: () {
              openProfile(context, _prayerRequest!.user.id);
            },
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  getProfilePic(context, user: _prayerRequest!.user) == null
                      ? null
                      : NetworkImage(getProfilePic(context,
                          user: pb.authStore.model as RecordModel)!),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: getProfilePic(context,
                          user: pb.authStore.model as RecordModel) ==
                      null
                  ? Text(
                      '${_prayerRequest!.user.getStringValue('first_name')[0]}${_prayerRequest!.user.getStringValue('last_name')[0]}'
                          .toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              _prayerRequest!.user.getStringValue('username'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                    formatDateTimeToHoursAgo(
                        format.parse(_prayerRequest!.created)),
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 8),
                Icon(Icons.public, size: 14, color: Colors.grey[600]),
              ],
            ),
            // trailing: PopupMenuButton(
            //   itemBuilder: (context) => [
            //     const PopupMenuItem(child: Text('Report')),
            //     const PopupMenuItem(child: Text('Share')),
            //   ],
            // ),
          ),
          // Prayer Request Content
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                urgentRequest(widget.data.urgent),
                const SizedBox(height: 12),
                Text(
                  widget.data.request,
                  style: const TextStyle(fontSize: 16),
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
                  icon: !isPraying! ? Icons.favorite_border : Icons.favorite,
                  label: 'Praying (${formatCount(isPrayingCount)})',
                  onTap: () {
                    addPraying(context);
                  },
                ),
                const SizedBox(width: 16),
                _PrayerAction(
                  icon: Icons.comment_outlined,
                  label: 'Comment (${formatCount(widget.data.comment.length)})',
                  onTap: () async {
                    final result = await showPrayerCommentOptions(context);
                    if (result != null) {
                      if (result == 'custom') {
                        // Handle custom prayer comment
                        showPrayerCommentSheet(context, widget.data);
                      } else {
                        // Handle predefined prayer comment
                        // result will contain the prayer type string
                        uploadComment(context, result);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container urgentRequest(bool urgent) {
    if (!urgent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Just talking to God',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
