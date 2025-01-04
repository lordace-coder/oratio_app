import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/widgets/posts/bottom_scaffold.dart';
import 'package:pocketbase/pocketbase.dart';

class PrayerRequestViewer extends StatefulWidget {
  final List<PrayerRequest> prayerRequests;
  final int initialIndex;

  const PrayerRequestViewer({
    super.key,
    required this.prayerRequests,
    required this.initialIndex,
  });

  @override
  State<PrayerRequestViewer> createState() => _PrayerRequestViewerState();
}

class _PrayerRequestViewerState extends State<PrayerRequestViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentIndex = 0;
  bool isPraying = false;
  int isPrayingCount = 0;
  intl.DateFormat format = intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  PrayerRequest? _prayerRequest;
  late PocketBase pb;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.animateTo(
      index / widget.prayerRequests.length,
      curve: Curves.easeInOut,
    );
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 8),
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
                      // Progress Bars
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: List.generate(
                            widget.prayerRequests.length,
                            (index) => Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                height: 3,
                                decoration: BoxDecoration(
                                  color: index <= _currentIndex
                                      ? Theme.of(context).primaryColor
                                      : index == _currentIndex
                                          ? Color.lerp(
                                              Colors.grey[300],
                                              Theme.of(context).primaryColor,
                                              _progressAnimation.value,
                                            )
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

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
                                        ? NetworkImage(getProfilePic(context,
                                            user: request.user)!)
                                        : null,
                                    child: getProfilePic(context,
                                                user: request.user) ==
                                            null
                                        ? Text(
                                            '${request.user.getStringValue('first_name')[0]}${request.user.getStringValue('last_name')[0]}'
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
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
                            color:
                                request.urgent ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Prayer Request Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.prayerRequests.length,
                  itemBuilder: (context, index) {
                    // final request = widget.prayerRequests[index];
                    _prayerRequest = widget.prayerRequests[index];
                    isPrayingCount = _prayerRequest!.praying.length;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Prayer Request Text
                        Text(
                          _prayerRequest!.request,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Navigation Buttons
          Positioned.fill(
            child: Row(
              children: [
                if (_currentIndex > 0)
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60,
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (_currentIndex < widget.prayerRequests.length - 1)
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60,
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
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
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
