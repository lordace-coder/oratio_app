import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/bloc/ads_bloc/ads_cubit.dart';
import 'package:oratio_app/bloc/ads_bloc/ads_state.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/central_cubit/central_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/ui/pages/priest/live_page.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/widgets/live_streams.dart';
import 'package:oratio_app/ui/widgets/posts/prayer_community.dart';
import 'package:oratio_app/ui/widgets/prayer_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedsListScreen extends StatefulWidget {
  const FeedsListScreen({super.key});

  @override
  FeedsListScreenState createState() => FeedsListScreenState();
}

class FeedsListScreenState extends State<FeedsListScreen> {
  final ScrollController _scrollController = ScrollController();
  late PocketBase pb;
  bool _isLoadingMore = false;
  bool _hasMoreFeeds = true;
  int unreadNotificationCount = 0;
  @override
  void initState() {
    super.initState();
    unreadNotificationCount =0;
        
    _scrollController.addListener(_onScroll);
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feeds = context.read<CentralCubit>().state;
      if (feeds.isEmpty) {
        context.read<CentralCubit>().getFeeds();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Load more when we're 100 pixels from the bottom
      if (!_isLoadingMore && _hasMoreFeeds) {
        _loadMoreFeeds();
      }
    }
  }

  Future<void> _loadMoreFeeds() async {
    setState(() {
      _isLoadingMore = true;
    });
    final newFeeds = await context.read<CentralCubit>().getMoreFeeds();
    if (newFeeds.isEmpty) {
      setState(() {
        _hasMoreFeeds = false;
      });
    }
    setState(() {
      _isLoadingMore = false;
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!pb.authStore.isValid) {
      pb.authStore.clear();
    }
unreadNotificationCount = context.watch<NotificationCubit>().unreadNotificationCount();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CathsApp',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteNames.profile);
                          },
                          child: Icon(
                            FontAwesomeIcons.userTie,
                            color: Colors.black.withOpacity(0.6),
                            size: 21,
                          ),
                        ),
                        const Gap(15),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteNames.connect);
                          },
                          child: Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Colors.black.withOpacity(0.8),
                            size: 21,
                          ),
                        ),
                        const Gap(15),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(RouteNames.notifications),
                          child: Badge(
                            isLabelVisible: unreadNotificationCount != 0,
                            label: Text(unreadNotificationCount.toString()),
                            child: Icon(
                              FontAwesomeIcons.bell,
                              color: Colors.black.withOpacity(0.7),
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[350],
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await context.read<CentralCubit>().getFeeds();
          context.read<PrayerRequestCubit>().refresh();
        },
        child: BlocBuilder<CentralCubit, List>(
          builder: (context, feeds) {
            if (feeds.isEmpty) {
              return const NoFeedsWidget();
            } else {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const ColoredBox(
                      color: Colors.white,
                      child: PrayerRequestGroupsList(),
                    ),
                    context.watch<CentralCubit>().liveParishes.isNotEmpty
                        ? LiveWidget(
                            parishId: context
                                .read<CentralCubit>()
                                .liveParishes
                                .first
                                .id,
                            currentAttendees: 'Bright and others',
                            onJoinPressed: () {
                              Navigator.of(context).push(LiveMassPage.route(
                                  parishId: context
                                      .read<CentralCubit>()
                                      .liveParishes
                                      .first
                                      .id));
                            },
                            parishName: context
                                .read<CentralCubit>()
                                .liveParishes
                                .first
                                .getStringValue('name'),
                          )
                        : const SizedBox.shrink(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: feeds.length + 1,
                      itemBuilder: (context, index) {
                        if (index == feeds.length) {
                          return _isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : !_hasMoreFeeds
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: Text('You are all caught up!'),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                        }
                        final feed = feeds[index];
                        if (feed is Post) {
                          return CommunityPostCard(post: feed);
                        } else if (feed is Ad) {
                          context.read<AdsCubit>().incrementViews(feed.id);

                          return AdCard(
                            onCancel: () {
                              context.read<CentralCubit>().deleteAd(feed.id);
                            },
                            title: feed.title,
                            description: feed.description,
                            imageUrl: feed.image!,
                            onTap: () {
                              context.read<AdsCubit>().incrementClicks(feed.id);
                            },
                            ctaText: feed.callToAction,
                          );
                          // Handle other feed types if any
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class NoFeedsWidget extends StatelessWidget {
  const NoFeedsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
              height: 100,
              'https://lottie.host/fece67a7-2389-4c66-b33c-6eb5bb658347/dK1IxI9mjB.json'),
          const Row(),
          const Gap(20),
          const Text(
            'Join A Community to start seeing feeds',
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                    child: BookingButton(
                        label: 'Join Community',
                        isEnabled: true,
                        onPressed: () {
                          context.pushNamed(RouteNames.communitypage);
                        })),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AdCard extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  final String? ctaText;
  final double? discount;
  const AdCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
    this.ctaText,
    this.discount,
    required this.onCancel,
  });
  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  bool isVisible = true;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => isVisible = false);
                        widget.onCancel();
                      },
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.3),
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.darken,
                    child: Image.network(
                      widget.imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.ctaText != null)
                    CustomButton(
                      onTap: widget.onTap,
                      text: widget.ctaText!,
                    ),
                  if (widget.discount != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '${widget.discount?.toInt()}% OFF',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Text(
                            widget.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 3,
          left: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(1),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              'AD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(30),
          color: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class LiveWidget extends StatefulWidget {
  final String parishName;
  final String currentAttendees;
  final VoidCallback onJoinPressed;
  final String parishId;
  const LiveWidget({
    super.key,
    required this.parishId,
    required this.parishName,
    required this.currentAttendees,
    required this.onJoinPressed,
  });

  @override
  _LiveWidgetState createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade400,
          width: 2.0,
        ),
        // borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(14.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.red.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.white,
                                  size: 12.0,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.parishName,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Row(
                //   children: [
                //     Icon(
                //       Icons.people_outline,
                //       size: 16.0,
                //       color: Colors.grey[600],
                //     ),
                //     const SizedBox(width: 4.0),
                //     Text(
                //       '${widget.currentAttendees} listening',
                //       style: TextStyle(
                //         color: Colors.grey[600],
                //         fontSize: 14.0,
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onJoinPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2.0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headphones),
                          SizedBox(width: 8.0),
                          Text(
                            'Join Live Mass',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
}
