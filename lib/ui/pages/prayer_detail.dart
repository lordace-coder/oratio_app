import 'package:flutter/material.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';

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

  @override
  Widget build(BuildContext context) {
    final request = widget.prayerRequests[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Custom App Bar with Progress Indicator
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      // Progress Indicator
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
                                child: LinearProgressIndicator(
                                  value: index < _currentIndex
                                      ? 1
                                      : index == _currentIndex
                                          ? _progressAnimation.value
                                          : 0,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // User Info
                      ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          backgroundImage:
                              request.user.getStringValue('avatar') != null
                                  ? NetworkImage(
                                      request.user.getStringValue('avatar'))
                                  : null,
                          child: request.user.getStringValue('avatar') == null
                              ? Text(
                                  '${request.user.getStringValue('first_name')[0]}${request.user.getStringValue('last_name')[0]}'
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          request.user.getStringValue('username'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTimeToHoursAgo(
                                DateTime.parse(request.created),
                              ),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
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
                    final request = widget.prayerRequests[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Urgent Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
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
                                color: request.urgent
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Prayer Request Text
                          Text(
                            request.request,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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
                // Previous Button
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
                // Next Button
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
      // Bottom Actions
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              icon: Icons.favorite_border,
              label: 'Pray (${formatCount(request.praying.length)})',
              onTap: () {
                // Implement prayer action
              },
            ),
            _ActionButton(
              icon: Icons.comment_outlined,
              label: 'Comment (${formatCount(request.comment.length)})',
              onTap: () {
                // Implement comment action
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
            Icon(icon, size: 24),
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
