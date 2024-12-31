import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:pocketbase/pocketbase.dart';

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
    print(image);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: getCommunity(context, communityId: widget.communityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data!;
              print(data.image);
              final isMember = (data.allMembers).contains(getUser(context).id);
              final isLeader = data.leader.id == getUser(context).id;
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section with Gradient Overlay
                        Container(
                          height: 380,
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
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                              ),
                              // Content Overlay
                              Container(
                                decoration: BoxDecoration(
                                  image: data.image == null
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(data.image!),
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
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                              ),
                              // Community Details
                              Positioned(
                                bottom: 32,
                                left: 24,
                                right: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(20),
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
                          child: Row(
                            children: [
                              Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF8E2DE2)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          image: NetworkImage(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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

                        // Description Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
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
                        Container(
                          margin: const EdgeInsets.all(24),
                          child: buildGradientButton(
                            isMember ? "Welcome Back" : 'Join Community',
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
                      ],
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
                          isLeader
                              ? PopupMenuButton(
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
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Community'))
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrayerCommunityCreationPage(
                                                    community: data,
                                                  )));
                                    }
                                  },
                                )
                              : const SizedBox.shrink()
                          PopupMenuButton(
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
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit Community'))
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PrayerCommunityCreationPage(
                                              community: data,
                                            )));
                              }
                            },
                          )
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
