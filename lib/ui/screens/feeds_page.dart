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
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/widgets/posts/prayer_community.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedsListScreen extends StatefulWidget {
  const FeedsListScreen({super.key});

  @override
  _FeedsListScreenState createState() => _FeedsListScreenState();
}

class _FeedsListScreenState extends State<FeedsListScreen> {
  final ScrollController _scrollController = ScrollController();
  late PocketBase pb;
  bool _isLoadingMore = false;
  bool _hasMoreFeeds = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feeds = context.read<CentralCubit>().state;
      if (feeds.isEmpty) {
        context.read<CentralCubit>().getFeeds();
      }
      try {
        context
            .read<PocketBaseServiceCubit>()
            .state
            .pb
            .collection('users')
            .authRefresh();
      } catch (e) {
        print('auth refresh in feeds screen failed pls logout');
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!pb.authStore.isValid) {
      pb.authStore.clear();

      return const Center(
        child: Text('Bad Error, Please Log Out and Login Again'),
      );
    }
    // redirect user to home page if first time
    SharedPreferences.getInstance().then((pref) {
      if (!AppRouter(pref: pref).opened()) {
        context.pushNamed(RouteNames.onboarding);
      }
    });
    final unreadNotificationCount =
        context.read<NotificationCubit>().unreadNotificationCount();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pushNamed(RouteNames.profile),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Hero(
                              tag: "my-profile",
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: getProfilePic(context,
                                            user: pb.authStore.model
                                                as RecordModel) ==
                                        null
                                    ? null
                                    : NetworkImage(getProfilePic(context,
                                        user: pb.authStore.model
                                            as RecordModel)!),
                                radius: 20,
                                child: getProfilePic(context,
                                            user: pb.authStore.model
                                                as RecordModel) ==
                                        null
                                    ? const Icon(FontAwesomeIcons.user)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(RouteNames.profile);
                              },
                              child: Text(
                                pb.authStore.model.data['username'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteNames.createPrayerRequest);
                          },
                          child: const Icon(
                            FontAwesomeIcons.circlePlus,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteNames.connect);
                          },
                          child: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(RouteNames.notifications),
                          child: Badge(
                            isLabelVisible: unreadNotificationCount != 0,
                            label: Text(unreadNotificationCount.toString()),
                            child: const Icon(
                              FontAwesomeIcons.bell,
                              color: Colors.white70,
                              size: 20,
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
          setState(() {
            _hasMoreFeeds = true;
          });
        },
        child: BlocBuilder<CentralCubit, List>(
          builder: (context, feeds) {
            if (feeds.isEmpty) {
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
            } else {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
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
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text('You are all caught up!'),
                                ),
                              )
                            : const SizedBox.shrink();
                  }
                  final feed = feeds[index];
                  if (feed is Post) {
                    return CommunityPostCard(post: feed);
                  } else if (feed is PrayerRequest) {
                    return PrayerRequestCard(data: feed);
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
              );
            }
          },
        ),
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
