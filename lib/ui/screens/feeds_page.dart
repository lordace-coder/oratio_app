import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
      context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .collection('users')
          .authRefresh();
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
                  } else {
                    // Handle other feed types if any
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
