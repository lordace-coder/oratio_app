import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/pages/create_new_post.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/image_viewer.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPostCard extends StatefulWidget {
  const CommunityPostCard({super.key, required this.post, this.inPage = false});
  final Post post;
  final bool inPage;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextHeight();
    });
  }

  void _calculateTextHeight() {
    if (!mounted) return;

    final textSpan = _buildTextSpanWithLinks(widget.post.post);

    const TextDirection dir = TextDirection.ltr;
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: dir,
      maxLines: _maxLines,
    );

    final constraintWidth = MediaQuery.of(context).size.width - 40;
    textPainter.layout(maxWidth: constraintWidth);

    if (mounted) {
      setState(() {
        _shouldShowMoreButton = textPainter.didExceedMaxLines;
      });
    }
  }

  TextSpan _buildTextSpanWithLinks(String text) {
    // Regular expression for detecting URLs
    final urlRegExp = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final List<TextSpan> textSpans = [];
    final matches = urlRegExp.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the link
      if (match.start > currentIndex) {
        textSpans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: Theme.of(context).textTheme.bodyLarge,
        ));
      }

      // Add the link
      final url = text.substring(match.start, match.end);
      textSpans.add(TextSpan(
        text: url,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri uri =
                Uri.parse(url.startsWith('http') ? url : 'https://$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
      ));

      currentIndex = match.end;
    }

    // Add remaining text after the last link
    if (currentIndex < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(currentIndex),
        style: Theme.of(context).textTheme.bodyLarge,
      ));
    }

    return TextSpan(children: textSpans);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;
    final data = widget.post;
    hasLiked ??= widget.post.likes.contains(user.id);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              if (!widget.inPage) {
                try {
                  openCommunity(context, widget.post.communityId!);
                } catch (e) {
                  NotificationService.showError('Something went wrong');
                }
              }
            },
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: widget.post.getAvatar(context) != null
                  ? CachedNetworkImageProvider(widget.post.getAvatar(context)!)
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
            trailing: user.id == widget.post.author.getStringValue('leader')
                ? PopupMenuButton<String>(
                    position: PopupMenuPosition.under,
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreatePostPage(postToEdit: widget.post),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit Post'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: Text('Share Post'),
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: _buildTextSpanWithLinks(widget.post.post),
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
          if (widget.post.image!.isNotEmpty)
            GestureDetector(
              onTap: () {
                openImageView(context, widget.post.image!,
                    imageUrl: widget.post.image);
              },
              onLongPress: () async {
                var save = await confirm(
                  context,
                  content: const Text('Do you want to save this image?'),
                );
                if (save) {
                  FileDownloadHandler.downloadRawFile(
                      context, widget.post.image!,
                      isvideo: false);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 9),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.post.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PostAction(
                  icon: !hasLiked! ? Icons.favorite_border : Icons.favorite,
                  label: widget.post.likes.length.toString(),
                  onTap: () async {
                    final pb = context.read<PocketBaseServiceCubit>().state.pb;
                    final postHelper = PostHelper(pb);
                    if (hasLiked!) {
                      await postHelper.dislikePost(data.id);
                      (data.likes).remove(data.id);
                    } else {
                      await postHelper.likePost(data.id);
                      (data.likes).add(data.id);
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
                  icon: FontAwesomeIcons.eye,
                  label: 'View Post',
                  onTap: () {
                    openPostDetail(context, widget.post.id);
                  },
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

    Future<void> deletePrayerRequest(
        BuildContext context, PrayerRequest request) async {
      final bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
                'Are you sure you want to delete this prayer request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete) {
        try {
          await pb.collection('prayer_requests').delete(request.id);
          NotificationService.showSuccess(
              'Prayer request deleted successfully');
          Navigator.of(context).pop(); // Close the current screen
          setState(() {});
        } catch (e) {
          NotificationService.showError(
              'Error occurred while deleting prayer request');
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 1,
      ),
      color: Colors.white,
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
                      : CachedNetworkImageProvider(
                          getProfilePic(context, user: _prayerRequest!.user)!),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: getProfilePic(context, user: _prayerRequest!.user) == null
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
            trailing: _prayerRequest!.user.id == pb.authStore.model.id
                ? PopupMenuButton<String>(
                    position: PopupMenuPosition.under,
                    onSelected: (value) {
                      if (value == 'delete') {
                        deletePrayerRequest(context, _prayerRequest!);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete Prayer'),
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  )
                : null,
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
                  iscomment: true,
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
  final bool iscomment;

  const _PrayerAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.iscomment = false});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: iscomment ? Colors.black : Colors.red,
      ),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black.withOpacity(.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withOpacity(0.5)),
        ),
      ),
    );
  }
}
