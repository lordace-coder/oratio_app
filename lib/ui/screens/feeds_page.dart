import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/live_streams.dart';
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

class _FeedsListScreenState extends State<FeedsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  void getPosts() {
    try {
      final postState = context.read<PostCubit>().state;
      // if (postState is PostLoaded) {
      //   if (postState.posts.isEmpty) {
      //     context.read<PostCubit>().fetchPosts();
      //   }
      //   return;
      // }
      // if (postState is! PostLoaded && postState is! PostError) {
      //   context.read<PostCubit>().fetchPosts();
      // }
      context.read<PostCubit>().fetchPosts();
      return;
    } catch (e) {}
  }

  void getPrayerRequests() {
    try {
      final prayerRequestsState = context.read<PrayerRequestCubit>().state;
      // if (postState is PostLoaded) {
      //   if (postState.posts.isEmpty) {
      //     context.read<PostCubit>().fetchPosts();
      //   }
      //   return;
      // }
      // if (postState is! PostLoaded && postState is! PostError) {
      //   context.read<PostCubit>().fetchPosts();
      // }
      context.read<PrayerRequestCubit>().fetchPrayerRequests();
      return;
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPosts();
      context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .collection('users')
          .authRefresh();
      getPrayerRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    getPosts();
    // redirect user to home page if first time
    SharedPreferences.getInstance().then((pref) {
      if (!AppRouter(pref: pref).opened()) {
        context.pushNamed(RouteNames.onboarding);
        print('navigating');
      }
    });
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        context.pushNamed(RouteNames.profile),
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
                                          backgroundImage: getProfilePic(
                                                      context,
                                                      user: pb.authStore.model
                                                          as RecordModel) ==
                                                  null
                                              ? null
                                              : NetworkImage(getProfilePic(
                                                  context,
                                                  user: pb.authStore.model
                                                      as RecordModel)!),
                                          radius: 20,
                                          child: getProfilePic(context,
                                                      user: pb.authStore.model
                                                          as RecordModel) ==
                                                  null
                                              ? const Icon(
                                                  FontAwesomeIcons.user)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  buildIconButton(
                                    icon: FontAwesomeIcons.magnifyingGlass,
                                    onTap: () {
                                      context.pushNamed(RouteNames.connect);
                                    },
                                  ),
                                  const Gap(8),
                                  buildIconButton(
                                    icon: FontAwesomeIcons.bell,
                                    onTap: () => context
                                        .pushNamed(RouteNames.notifications),
                                    hasNotification: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Community Posts'),
                  Tab(text: 'Prayer Requests'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Community Posts Tab
            RefreshIndicator.adaptive(
              onRefresh: () async {
                await context.read<PostCubit>().fetchPosts();
              },
              child:
                  ListView(padding: const EdgeInsets.only(top: 8), children: [
                // TODO build story section (updates)
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //   child: buildStorySection(context),
                // ),
                BlocConsumer<PostCubit, PostState>(
                  listener: (context, state) {
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    if (state is PostLoaded) {
                      if (state.posts.isEmpty) {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: BookingButton(
                                            label: 'Join Community',
                                            isEnabled: true,
                                            onPressed: () {
                                              context.pushNamed(
                                                  RouteNames.communitypage);
                                            })),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            ...state.posts.map((post) => CommunityPostCard(
                                  post: post,
                                ))
                          ],
                        );
                      }
                    }
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  },
                ),
                // card for a post item
              ]),
            ),

            // Prayer Requests Tab
            BlocConsumer<PrayerRequestCubit, PrayerRequestState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                if (state is PrayerRequestLoaded) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async {
                      await context
                          .read<PrayerRequestCubit>()
                          .fetchPrayerRequests();
                    },
                    child: ListView.builder(
                      itemCount: state.prayerRequests.length,
                      padding: const EdgeInsets.only(top: 8),
                      itemBuilder: (context, index) => PrayerRequestCard(
                        data: state.prayerRequests[index],
                      ),
                    ),
                  );
                }
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
                        'Find friends and family to be up to date on thier prayer requests',
                        textAlign: TextAlign.center,
                      ),
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                                child: BookingButton(
                                    label: 'Find Friends',
                                    isEnabled: true,
                                    onPressed: () {
                                      context
                                          .pushNamed(RouteNames.communitypage);
                                    })),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteNames.createPrayerRequest);
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
