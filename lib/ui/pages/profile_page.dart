import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/central_cubit/central_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List? searchResult;
  bool showAllParishes = false;
  bool showAllCommunities = false;

  void getfollowing(BuildContext context) async {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    final currentUser = pb.authStore.model as RecordModel;
    final result = await pb.collection('users').getList();
    final searchResults = result.items
        .where((e) => e.getListValue('followers').contains(currentUser.id))
        .toList();
    if (mounted) {
      setState(() {
        searchResult = searchResults;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getfollowing(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchResult = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await context.read<ProfileDataCubit>().getMyProfile();
        },
        child: BlocConsumer<ProfileDataCubit, ProfileDataState>(
          listener: (context, state) {},
          builder: (context, state) {
            getfollowing(context);
            if (state is ProfileDataLoaded) {
              final data = state.profile;
              final pb = context.read<PocketBaseServiceCubit>().state.pb;

              return CustomScrollView(slivers: [
                // Custom App Bar with Gradient and Profile Info
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF),
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          // Back Button
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () => context.pop(),
                                    icon: const Icon(
                                      FontAwesomeIcons.chevronLeft,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                          onTap: () {
                                            Share.share(
                                                "Follow me up on CathsApp https://cathsapp.ng/app/profilevisitor/${pb.authStore.model.id}");
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.share),
                                              Gap(5),
                                              Text("Share")
                                            ],
                                          ))
                                    ];
                                  },
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                )
                              ],
                            ),
                          ),

                          // Profile Info
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  // display image here
                                  child: Hero(
                                    tag: "my-profile",
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: getProfilePic(context,
                                                  user: pb.authStore.model
                                                      as RecordModel) ==
                                              null
                                          ? const Color(0xFF8B80FF)
                                          : null,
                                      backgroundImage: getProfilePic(context,
                                                  user: pb.authStore.model
                                                      as RecordModel) ==
                                              null
                                          ? null
                                          : CachedNetworkImageProvider(
                                              getProfilePic(context,
                                                  user: pb.authStore.model
                                                      as RecordModel)!),
                                      child: getProfilePic(context,
                                                  user: pb.authStore.model
                                                      as RecordModel) ==
                                              null
                                          ? const Icon(
                                              FontAwesomeIcons.userAstronaut,
                                              color: Colors.white,
                                              size: 40,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Text(
                                  getFullName(data.user),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                // Text(
                                //   data.user.getStringValue('username'),
                                //   style: const TextStyle(
                                //     fontSize: 14,
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.w300,
                                //     letterSpacing: 0.5,
                                //   ),
                                // ),
                                Text(
                                  searchResult != null
                                      ? '${(pb.authStore.model as RecordModel).getListValue('followers').length} followers · ${searchResult?.length} following'
                                      : '0 followers · 0 following',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Gap(12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                        'Edit Profile', Icons.edit, () {
                                      context.pushNamed(RouteNames.editprofile);
                                    }),
                                    if ((pb.authStore.model as RecordModel)
                                            .getBoolValue('verified') ==
                                        false)
                                      _buildActionButton(
                                          'Verify Email', Icons.verified, () {
                                        try {
                                          pb
                                              .collection('users')
                                              .requestVerification((pb.authStore
                                                      .model as RecordModel)
                                                  .getStringValue('email'));
                                          NotificationService.showSuccess(
                                              'Verification Link Sent. Check your email or spam section',
                                              duration:
                                                  const Duration(seconds: 6));
                                        } catch (error) {
                                          NotificationService.showError(
                                              'Verification failed. Ensure you have a correct email');
                                        }
                                      }),
                                    _buildActionButton(
                                        'Settings  ', Icons.settings, () {
                                      context
                                          .pushNamed(RouteNames.settingsPage);
                                    }),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, 0),
                    child: Column(
                      children: [
                        _buildSection(
                          "Parish You're Attending",
                          FontAwesomeIcons.church,
                          [
                            ...data.parish
                                .take(showAllParishes ? data.parish.length : 3)
                                .map((item) => _buildParishItem(
                                        item.getStringValue('name'),
                                        label: 'visit', onAction: () {
                                      openParish(context, item.id);
                                    })),
                            if (data.parish.length > 3)
                              _buildSeeMoreButton(
                                showAllParishes,
                                () {
                                  setState(() {
                                    showAllParishes = !showAllParishes;
                                  });
                                },
                              ),
                          ],
                        ),
                        _buildSection(
                          "Communities You're In",
                          FontAwesomeIcons.church,
                          [
                            ...data.community
                                .take(showAllCommunities
                                    ? data.community.length
                                    : 3)
                                .map((item) => _buildParishItem(
                                        item.getStringValue('community'),
                                        label: 'visit', onAction: () {
                                      openCommunity(context, item.id);
                                    })),
                            if (data.community.length > 3)
                              _buildSeeMoreButton(
                                showAllCommunities,
                                () {
                                  setState(() {
                                    showAllCommunities = !showAllCommunities;
                                  });
                                },
                              ),
                          ],
                        ),
                        _buildSection(
                          "Contact Information",
                          FontAwesomeIcons.addressBook,
                          [
                            _buildContactItem(
                                data.contact, context, data.userId),
                            // _buildAddButton("Add Contact Information"),
                          ],
                        ),
                        _buildSection(
                          "Select Language",
                          FontAwesomeIcons.language,
                          [
                            _buildLanguageItem("English - US"),
                          ],
                        ),
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildGradientButton(
                                "Customer Service",
                                FontAwesomeIcons.headset,
                                const Color(0xFF6C63FF),
                                AppColors.primary,
                                () {
                                  openWhatsApp(
                                      phoneNumber: '+2347032096095',
                                      message:
                                          'Im looking for customer support');
                                },
                              ),
                              const Gap(12),
                              _buildGradientButton(
                                "Log Out",
                                FontAwesomeIcons.rightFromBracket,
                                const Color(0xFFFF6B6B),
                                const Color(0xFFFF3131),
                                () async {
                                  context.read<CentralCubit>().logout();
                                },
                              ),
                            ],
                          ),
                        ),
                        const Gap(32),
                      ],
                    ),
                  ),
                ),
              ]);
            }
            context.read<ProfileDataCubit>().getMyProfile();

            return const Center(child: LinearProgressIndicator());

            // Profile Sections
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const Gap(8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 1, 10, 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const Gap(16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildParishItem(String name, {Function()? onAction, String? label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          if (onAction != null && label != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      String contact, BuildContext context, String profileId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              contact.isNotEmpty ? contact : 'Add contact',
              style: TextStyle(
                  fontSize: 16,
                  color: contact.isNotEmpty
                      ? const Color(0xFF4A4A4A)
                      : Colors.black.withOpacity(0.3),
                  fontStyle: contact.isNotEmpty ? null : FontStyle.italic),
            ),
          ),
          TextButton(
            onPressed: () async {
              context.pushNamed(RouteNames.editprofile);
            },
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String language) {
    return Row(
      children: [
        Expanded(
          child: Text(
            language,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            NotificationService.showInfo('Feature coming soon',
                duration: Durations.extralong4);
          },
          child: const Text(
            "Choose Language",
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    String text,
    IconData icon,
    Color startColor,
    Color endColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const Gap(12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(bool showAll, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        showAll ? 'See Less' : 'See More',
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
