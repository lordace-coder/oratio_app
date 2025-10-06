import 'package:ace_toast/ace_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class CommunityCard extends StatelessWidget {
  final PrayerCommunity community;

  const CommunityCard({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final userId =
        getPocketBaseFromContext(context).authStore.model.id as String;

    bool joined = community.allMembers.contains(userId);
    int membersCount = community.members;
    print("image url: ${community.image}");
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

class ParishCard extends StatelessWidget {
  final Map<String, dynamic> parish;

  const ParishCard({super.key, required this.parish});

  @override
  Widget build(BuildContext context) {
    final church = RecordModel.fromJson(parish);
    final pb = getPocketBaseFromContext(context);

    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteNames.parishlanding, pathParameters: {
          'id': church.id,
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Enhanced church image with shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pb
                        .getFileUrl(
                          church,
                          church.getStringValue('image'),
                          thumb: '60 x 60',
                        )
                        .toString(),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[200]!,
                              Colors.grey[300]!,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.church_rounded,
                          color: Colors.grey[500],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      church.getStringValue('name').toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            church.getStringValue('location'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final String name;
  final String username;
  final String followers;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final String id;
  final String? profilePicture;

  const UserCard({
    super.key,
    this.profilePicture,
    required this.name,
    required this.username,
    required this.followers,
    required this.isFollowing,
    required this.onFollowTap,
    required this.id,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool? following;

  void followUser() {
    setState(() {
      following = true;
    });
    widget.onFollowTap.call();
  }

  @override
  void initState() {
    super.initState();
    following ??= widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteNames.profilepagevisitor,
          pathParameters: {'id': widget.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Enhanced avatar with gradient border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (widget.profilePicture != null ||
                            widget.profilePicture!.isNotEmpty)
                        ? CachedNetworkImageProvider(widget.profilePicture!)
                        : null,
                    child: (widget.profilePicture == null ||
                            widget.profilePicture!.isEmpty)
                        ? Text(
                            widget.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      widget.username,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const Gap(4),
                        Text(
                          '${widget.followers} followers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(12),
              // Enhanced follow button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: followUser,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: following!
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                            ),
                      color: following! ? Colors.grey[100] : null,
                      borderRadius: BorderRadius.circular(24),
                      border: following!
                          ? Border.all(color: Colors.grey[300]!, width: 1.5)
                          : null,
                      boxShadow: following!
                          ? null
                          : [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Text(
                      following! ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: following! ? Colors.grey[700] : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
