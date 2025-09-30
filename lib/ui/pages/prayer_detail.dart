import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:oratio_app/ui/widgets/prayer_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:math';
import 'dart:async';

class PrayerRequestViewer extends StatefulWidget {
  final List<PrayerRequest> prayerRequests;
  final int initialIndex;
  final List<UserPrayerRequestGroup> otherPrayerRequests;
  const PrayerRequestViewer(
      {super.key,
      required this.prayerRequests,
      required this.initialIndex,
      required this.otherPrayerRequests});

  @override
  State<PrayerRequestViewer> createState() => _PrayerRequestViewerState();
}

class _PrayerRequestViewerState extends State<PrayerRequestViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentIndex = 0;
  bool isPraying = false;
  int isPrayingCount = 0;
  intl.DateFormat format = intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  PrayerRequest? _prayerRequest;
  late PocketBase pb;
  final Map<String, Color> _backgroundColors = {};
  int? _currentUserGroupIndex;

  Color _getBackgroundColor(String requestId) {
    if (!_backgroundColors.containsKey(requestId)) {
      final random = Random();
      _backgroundColors[requestId] = Color.fromARGB(
        255,
        random.nextInt(128),
        random.nextInt(128),
        random.nextInt(128),
      );
    }
    return _backgroundColors[requestId]!;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1 / widget.prayerRequests.length,
    ).animate(_animationController);

    _animationController.value =
        widget.initialIndex / widget.prayerRequests.length;

    pb = context.read<PocketBaseServiceCubit>().state.pb;
    isPrayingCount = widget.prayerRequests[_currentIndex].praying.length;
    isPraying = widget.prayerRequests[_currentIndex].praying
        .contains(pb.authStore.model.id);
    _currentUserGroupIndex = _findCurrentUserGroupIndex();
  }

  int _findCurrentUserGroupIndex() {
    return widget.otherPrayerRequests.indexWhere((group) =>
        group.prayerRequests.first.id == widget.prayerRequests.first.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get canGoNext {
    if (_currentIndex < widget.prayerRequests.length - 1) return true;
    if (_currentUserGroupIndex != null &&
        _currentUserGroupIndex! < widget.otherPrayerRequests.length - 1)
      return true;
    return false;
  }

  bool get canGoPrevious {
    if (_currentIndex > 0) return true;
    if (_currentUserGroupIndex != null && _currentUserGroupIndex! > 0)
      return true;
    return false;
  }

  void _goToNext() {
    if (_currentIndex < widget.prayerRequests.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animationController.animateTo(
        _currentIndex / widget.prayerRequests.length,
        curve: Curves.easeInOut,
      );
    } else if (_currentUserGroupIndex != null &&
        _currentUserGroupIndex! < widget.otherPrayerRequests.length - 1) {
      // Go to next user's prayers
      final nextGroup = widget.otherPrayerRequests[_currentUserGroupIndex! + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrayerRequestViewer(
            prayerRequests: nextGroup.prayerRequests,
            initialIndex: 0,
            otherPrayerRequests: widget.otherPrayerRequests,
          ),
        ),
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animationController.animateTo(
        _currentIndex / widget.prayerRequests.length,
        curve: Curves.easeInOut,
      );
    } else if (_currentUserGroupIndex != null && _currentUserGroupIndex! > 0) {
      // Go to previous user's prayers
      final prevGroup = widget.otherPrayerRequests[_currentUserGroupIndex! - 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrayerRequestViewer(
            prayerRequests: prevGroup.prayerRequests,
            initialIndex: prevGroup.prayerRequests.length - 1,
            otherPrayerRequests: widget.otherPrayerRequests,
          ),
        ),
      );
    }
  }

  void _goToNextUser() {
    if (_currentUserGroupIndex != null &&
        _currentUserGroupIndex! < widget.otherPrayerRequests.length - 1) {
      final nextGroup = widget.otherPrayerRequests[_currentUserGroupIndex! + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrayerRequestViewer(
            prayerRequests: nextGroup.prayerRequests,
            initialIndex: 0,
            otherPrayerRequests: widget.otherPrayerRequests,
          ),
        ),
      );
    }
  }

  Future addPraying(BuildContext context, PrayerRequest data) async {
    final bool praying = data.praying.contains(pb.authStore.model.id);
    if (praying) {
      _prayerRequest?.praying.remove(pb.authStore.model.id);
    } else {
      _prayerRequest?.praying.add(pb.authStore.model.id);
    }
    setState(() {});
    try {
      if (praying) {
        await pb.collection('prayer_requests').update(data.id, body: {
          'praying-': [pb.authStore.model.id]
        });

        NotificationService.showWarning('You removed your prayer',
            duration: Durations.extralong4);
      } else {
        await pb
            .collection('prayer_requests')
            .update(widget.prayerRequests[_currentIndex].id, body: {
          'praying+': [pb.authStore.model.id]
        });

        NotificationService.showSuccess('Prayer said succesfully',
            duration: Durations.extralong4);
      }
    } catch (e) {
      // display error on ui
      NotificationService.showError('error occured while sending prayer');
    }
    setState(() {});
  }

  Future uploadComment(BuildContext context, String comment) async {
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final newComment = await pb.collection('comments').create(body: {
        'user': (pb.authStore.model as RecordModel).id,
        'comment': comment,
      });

      pb
          .collection('prayer_requests')
          .update(widget.prayerRequests[_currentIndex].id, body: {
        'comment+': [newComment.id]
      });
    } catch (e) {
      // display error on ui
      print('error occured in getComments $e');
    }
  }

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
        NotificationService.showSuccess('Prayer request deleted successfully');
        Navigator.of(context).pop(); // Close the current screen
        setState(() {});
      } catch (e) {
        NotificationService.showError(
            'Error occurred while deleting prayer request');
      }
    }
  }

  bool isOwner(PrayerRequest request) {
    return request.user.id == pb.authStore.model.id;
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
  Widget build(BuildContext context) {
    final request = widget.prayerRequests[_currentIndex];

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swipe left - normal navigation
          _goToNext();
        } else if (details.primaryVelocity! > 0) {
          // Swipe right - go to next user's requests
          _goToNextUser();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with user info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              openProfile(context, request.user.id);
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  backgroundImage: getProfilePic(context,
                                              user: request.user) !=
                                          null
                                      ? CachedNetworkImageProvider(
                                          getProfilePic(context,
                                              user: request.user)!)
                                      : null,
                                  child: getProfilePic(context,
                                              user: request.user) ==
                                          null
                                      ? Text(
                                          '${request.user.getStringValue('first_name')[0]}${request.user.getStringValue('last_name')[0]}'
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.user.getStringValue('username'),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formatDateTimeToHoursAgo(
                                            DateTime.parse(request.created),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (isOwner(request))
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  deletePrayerRequest(context, request),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: request.urgent
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.urgent
                            ? 'Urgent Prayer Request'
                            : 'Just talking to God',
                        style: TextStyle(
                          color: request.urgent ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer Request Content
              Expanded(
                child: Stack(
                  children: [
                    ColoredBox(
                      color: _getBackgroundColor(request.id),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            request.request,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Previous Button
                    if (canGoPrevious)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Hero(
                            tag:
                                'prev-button-${widget.prayerRequests[_currentIndex].id}',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.black.withOpacity(0.5),
                              onPressed: _goToPrevious,
                              heroTag: null, // Important: set this to null
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Next Button
                    if (canGoNext)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Hero(
                            tag:
                                'next-button-${widget.prayerRequests[_currentIndex].id}',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.black.withOpacity(0.5),
                              onPressed: _goToNext,
                              heroTag: null, // Important: set this to null
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
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
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                isFav: true,
                icon: widget.prayerRequests[_currentIndex].praying.contains(
                        getPocketBaseFromContext(context).authStore.model.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                label:
                    '${formatCount(widget.prayerRequests[_currentIndex].praying.length)} Praying',
                onTap: () {
                  // Implement prayer action
                  addPraying(context, request);
                },
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: request.comment.length <= 1
                    ? '${formatCount(request.comment.length)} Comment'
                    : '${formatCount(request.comment.length)} Comments',
                onTap: () async {
                  final result = await showPrayerCommentOptions(context);
                  if (result != null) {
                    if (result == 'custom') {
                      // Handle custom prayer comment
                      showPrayerCommentSheet(context, request);
                    } else {
                      // result will contain the prayer type string
                      uploadComment(context, result);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  bool isFav;
  _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFav = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isFav ? Colors.red : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
