import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/posts/prayer_community.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PrayerCommunityDetail extends StatefulWidget {
  const PrayerCommunityDetail({super.key, required this.communityId});

  final String communityId;

  @override
  State<PrayerCommunityDetail> createState() => _PrayerCommunityDetailState();
}

class _PrayerCommunityDetailState extends State<PrayerCommunityDetail> {
  String getAvaterUrl(RecordModel record) {
    final pb = getPocketBaseFromContext(context);

    final image =
        pb.getFileUrl(record, record.getStringValue('avatar')).toString();
    return image;
  }

  // Add a variable to store the fetched data
  PrayerCommunity? _communityData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteNames.mass);
        },
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        child: const Column(
          children: [
            Icon(
              Icons.book_rounded,
            ),
            Gap(10),
            Text(
              'BookMass',
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<PrayerCommunity?>(
          future: _communityData == null
              ? getCommunity(context, communityId: widget.communityId)
              : Future.value(_communityData),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              // Store the fetched data
              _communityData = snapshot.data!;
              final data = _communityData;
              final isMember = (data!.allMembers).contains(getUser(context).id);
              final isLeader = data.leader.id == getUser(context).id;
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _communityData = null;
                      });
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Section with Gradient Overlay
                          Container(
                            height: 180,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: [
                                // Background Image with Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF8E2DE2),
                                        AppColors.primary.withOpacity(0.9),
                                      ],
                                    ),
                                  ),
                                ),
                                // Content Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    image: data.image == null
                                        ? null
                                        : DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                data.image!),
                                            colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.5),
                                                BlendMode.darken),
                                            fit: BoxFit.cover),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                                // Community Details
                                Positioned(
                                  bottom: 32,
                                  left: 24,
                                  right: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.community,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Gap(8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons.userGroup,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '${data.members} ${data.members > 1 ? 'Members' : 'Member'}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Leader Section
                          Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                openProfile(context, data.leader.id);
                              },
                              child: Row(
                                children: [
                                  Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF8E2DE2)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                getAvaterUrl(data.leader),
                                              ),
                                              fit: BoxFit.cover)),
                                      child: data.leader
                                              .getStringValue('avatar')
                                              .isEmpty
                                          ? const Icon(
                                              FontAwesomeIcons.userTie,
                                              color: Color(0xFF8E2DE2),
                                              size: 24,
                                            )
                                          : null),
                                  const Gap(16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Community Leader',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        '${data.leader.getStringValue('first_name')} ${data.leader.getStringValue('last_name')}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          CreatePostSection(
                            communityId: data.id,
                            isLeader: isLeader,
                          ),

                          // Description Section
                          if (data.description.isNotEmpty)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About Community',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(16),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      data.description,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const Gap(32),

                          // Join Button
                          if (!isMember)
                            Container(
                              margin: const EdgeInsets.all(24),
                              child: buildGradientButton(
                                'Join Community',
                                FontAwesomeIcons.userPlus,
                                () async {
                                  if (isMember) {
                                    NotificationService.showWarning(
                                        'You are already a Member of this Community');
                                    return;
                                  }
                                  await joinCommunity(context,
                                      communityId: widget.communityId);
                                  setState(() {});
                                },
                              ),
                            ),

                          if (isMember)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Posts',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isMember)
                            FutureBuilder(
                                future: PostHelper(
                                        getPocketBaseFromContext(context))
                                    .getCommunityPosts(widget.communityId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      height: 300,
                                      width: double.infinity,
                                      child: shimmer.Shimmer.fromColors(
                                        baseColor: Colors.grey,
                                        highlightColor: Colors.white,
                                        child: const SizedBox.shrink(),
                                      ),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Text('No Recent Posts'),
                                    );
                                  }
                                  return Column(
                                    children: [
                                      for (final post in snapshot.data!)
                                        CommunityPostCard(
                                          inPage: true,
                                          post: post,
                                        ),
                                    ],
                                  );
                                })
                        ],
                      ),
                    ),
                  ),

                  // Custom App Bar
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
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
                          PopupMenuButton(
                            position: PopupMenuPosition.under,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.ellipsisVertical,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            itemBuilder: (context) => [
                              if (isLeader)
                                const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Community')),
                              const PopupMenuItem(
                                value: "invite",
                                child: Text("Invite "),
                              )
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PrayerCommunityCreationPage(
                                                community: data,
                                              )));
                                  break;
                                case 'invite':
                                  Share.shareUri(Uri.https("cathsapp.ng",
                                      '/app/communityDetailPage/${widget.communityId}'));
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 400,
                child: Lottie.asset('assets/lottie/anim1.json'),
              );
            }
            return Container();
          }),
    );
  }
}

class CreatePostSection extends StatefulWidget {
  const CreatePostSection(
      {super.key, required this.communityId, required this.isLeader});
  final String communityId;
  final bool isLeader;
  @override
  State<CreatePostSection> createState() => _CreatePostSectionState();
}

class _CreatePostSectionState extends State<CreatePostSection> {
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _loadDontShowAgainPreference();
  }

  Future<void> _loadDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = prefs.getBool('announcement') ?? false;
    });
  }

  void _updateDontShowAgainPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('announcement', value);
    if (mounted) {
      setState(() {
        _dontShowAgain = value;
      });
    }
  }

  void createPost() {
    context.pushNamed(RouteNames.createPost);
  }

  @override
  Widget build(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    final userModel = pb.authStore.model as RecordModel;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(pb
                    .getFileUrl(userModel, userModel.getStringValue('avatar'),
                        thumb: '60 x 60')
                    .toString()),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: createPost,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black38),
                      ),
                      child: const Text(
                        "Aa",
                        style: TextStyle(color: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: createPost,
                  icon: const Icon(Icons.send, color: Colors.black38))
            ],
          ),
          const Gap(10),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Share.shareUri(Uri.https("cathsapp.ng",
                      '/app/communityDetailPage/${widget.communityId}'));
                },
                style:
                    TextButton.styleFrom(backgroundColor: Colors.grey.shade50),
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.share, size: 14),
                    Gap(5),
                    Text(
                      'Invite',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    final demoPrayer = {
                      "title": "The Lord's Prayer",
                      "prayer":
                          '''Our Father, who art in heaven, hallowed be thy name. Thy kingdom come, thy will be done, on earth as it is in heaven. Give us this day our daily bread, and forgive us our trespasses, as we forgive those who trespass against us. And lead us not into temptation, but deliver us from evil. for thine is the kingdom, and the power, and the glory, for ever and ever.''',
                    };
                    context.pushNamed(
                      RouteNames.communityPrayersPage,
                      extra: demoPrayer,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    foregroundColor: Colors.green,
                  ),
                  child: const Row(
                    children: [
                      Icon(FontAwesomeIcons.prayingHands, size: 14),
                      Gap(5),
                      Text(
                        'Join Prayers',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  )),
              if (widget.isLeader)
                TextButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          bool checked = false;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.microphone,
                                      color: AppColors.green,
                                    ),
                                    const Gap(8),
                                    const Text('Announcement'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'You are about to make an announcement to the entire community. Please ensure your message is clear and concise.',
                                    ),
                                    const Gap(16),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: checked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              checked = value!;
                                            });
                                          },
                                        ),
                                        const Text('Don\'t show again'),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _updateDontShowAgainPreference(checked);
                                      _createAnnoucement();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade50),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.microphone,
                          size: 14,
                          color: AppColors.green,
                        ),
                        const Gap(5),
                        const Text(
                          'Announcement',
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ))
            ],
          )
        ],
      ),
    );
  }

  void _createAnnoucement() {
    context.pushNamed(RouteNames.annoucementPage,
        pathParameters: {'id': widget.communityId});
  }
}
