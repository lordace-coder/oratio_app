import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();
  List<PrayerCommunity> communities = [];
  late PocketBase pb;

  void loadData({String? query}) async {
    setState(() {
      _loading = true;
    });
    final data = await getCommunities(context,
        filter: query == null
            ? null
            : 'community ~ "$query" || leader.username ~"$query"');
    communities = data;

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom Gradient App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, const Color(0xFF4A00E0)],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Prayer Communities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                background: Stack(
                  children: [
                    // Decorative pattern overlay
                    Opacity(
                      opacity: 0.4,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/wallet_bg.jpeg'),
                            repeat: ImageRepeat.noRepeat,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            actions: [
              (pb.authStore.model as RecordModel).getBoolValue('priest')
                  ? IconButton(
                      onPressed: () {
                        context.pushNamed(RouteNames.createCommunityPage);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    )
                  : Container(),
              const Gap(8),
            ],
          ),

          // Search Bar Section
          Builder(
            builder: (
              BuildContext context,
            ) {
              if (_loading && communities.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Lottie.asset('assets/lottie/anim1.json'),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (query) {
                          loadData(query: query);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Find Community...',
                          border: InputBorder.none,
                          icon:
                              Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        ...communities
                            .map((i) => buildCommunityListItem(context, i))
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildFeaturedCard() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.userGroup,
                        color: Colors.white,
                        size: 12,
                      ),
                      Gap(8),
                      Text(
                        '1.2K Members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                const Text(
                  'Sacred Heart Society',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                const Text(
                  'Daily prayers and spiritual guidance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommunityListItem(
      BuildContext context, PrayerCommunity community) {
    final userId = pb.authStore.model.id as String;

    bool joined = community.allMembers.contains(userId);
    int membersCount = community.members;
    return InkWell(
      onTap: () {
        openCommunity(context, community.id);
      },
      child: StatefulBuilder(builder: (context, rebuild) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: community.image != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(community.image!),
                          fit: BoxFit.cover,
                          onError: (error, stack) {
                            debugPrint('error occured loading image $error');
                          })
                      : null,
                ),
                child: community.image == null
                    ? Icon(
                        FontAwesomeIcons.church,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.community,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.userGroup,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const Gap(4),
                        Text(
                          '$membersCount Members',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Gap(12),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (joined) {
                    return NotificationService.showInfo(
                        'You are already a Member');
                  }
                  await joinCommunity(context, communityId: community.id,
                      onError: () {
                    NotificationService.showError(
                        'Error occured while joining community');
                  });
                  rebuild(() {
                    joined = true;
                    membersCount++;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    joined ? 'Joined' : 'Join',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
