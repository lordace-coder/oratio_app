import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/pages/chat_page.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class ProfileVisitorPage extends StatefulWidget {
  const ProfileVisitorPage({super.key, required this.id});
  final String id;

  @override
  State<ProfileVisitorPage> createState() => _ProfileVisitorPageState();
}

class _ProfileVisitorPageState extends State<ProfileVisitorPage> {
  @override
  Widget build(BuildContext context) {
    context.read<ProfileDataCubit>().visitProfile(widget.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await context.read<ProfileDataCubit>().visitProfile(widget.id);
        },
        child: BlocConsumer<ProfileDataCubit, ProfileDataState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileDataLoading || state is ProfileDataInitial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state is ProfileDataLoaded) {
              final pb = context.read<PocketBaseServiceCubit>().state.pb;
              if (state.guestProfile == null) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              final data = state.guestProfile;
              bool isfollowing = data!.user
                  .getListValue('followers')
                  .contains(getUser(context).id);
              final communities = data.community.where((e) {
                return e.getStringValue('leader') == data.user.id;
              }).toList();

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
                            child: Container(
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
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: getProfilePic(context,
                                                user: pb.authStore.model
                                                    as RecordModel) ==
                                            null
                                        ? const Color(0xFF8B80FF)
                                        : null,
                                    backgroundImage: getProfilePic(context,
                                                user:
                                                    state.guestProfile!.user) ==
                                            null
                                        ? null
                                        : CachedNetworkImageProvider(
                                            getProfilePic(context,
                                                user:
                                                    state.guestProfile!.user)!),
                                    child: getProfilePic(context,
                                                user:
                                                    state.guestProfile!.user) ==
                                            null
                                        ? const Icon(
                                            FontAwesomeIcons.userAstronaut,
                                            color: Colors.white,
                                            size: 40,
                                          )
                                        : null,
                                  ),
                                ),
                                const Gap(16),
                                Text(
                                  '${getFullName(data.user)} (${data.user.getStringValue('username')})',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    (data.user.getBoolValue('priest'))
                                        ? '· Priest ·'
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Gap(12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isfollowing
                                        ? _buildActionButton(
                                            "Message", FontAwesomeIcons.message,
                                            () {
                                            setState(() {
                                              isfollowing = !isfollowing;
                                            });
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (_) => ChatPage(
                                                          profile: data,
                                                        )));
                                          })
                                        : _buildActionButton("Connect",
                                            FontAwesomeIcons.penToSquare, () {
                                            setState(() {
                                              isfollowing = !isfollowing;
                                            });
                                            followUser(context,
                                                targetUserId: data.user.id);
                                          }),
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
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, 0),
                    child: isfollowing
                        ? Column(
                            children: [
                              if (state.guestProfile!.parish.isNotEmpty)
                                _buildSection(
                                    'Parish', FontAwesomeIcons.church, [
                                  ...state.guestProfile!.parish.map((item) =>
                                      _buildParishItem(
                                          item.getStringValue('name'),
                                          label: 'visit', onAction: () {
                                        openParish(context, item.id);
                                      }))
                                ]),
                              if (state.guestProfile!.community.isNotEmpty)
                                _buildSection(
                                    'Community', FontAwesomeIcons.church, [
                                  ...state.guestProfile!.community.map((item) =>
                                      _buildParishItem(
                                          item.getStringValue('community'),
                                          label: 'visit', onAction: () {
                                        openCommunity(context, item.id);
                                      }))
                                ]),
                              if (data.user
                                  .getStringValue('phone_number')
                                  .isNotEmpty)
                                _buildSection('Contact Information',
                                    FontAwesomeIcons.userTie, [
                                  _buildParishItem(
                                      data.user.getStringValue('phone_number'),
                                      label: 'copy', onAction: () {
                                    copyToClipboard(
                                        context: context,
                                        successMessage: 'Copied succesfully',
                                        text: data.user
                                            .getStringValue('phone_number'));
                                  }),
                                ]),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                    'Connect with this user to view profile information'),
                              ),
                            ],
                          ),
                  ),
                ),
              ]);
            }

            return const Center(
              child: CircularProgressIndicator(),
            );

            // Profile Sections
          },
        ),
      ),
    );
  }

  Future<void> copyToClipboard({
    required String text,
    required BuildContext context,
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted) {
        NotificationService.showSuccess(
          successMessage ?? 'Copied to clipboard',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService.showError(
          successMessage ?? 'Failed to copy',
        );
      }
    }
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildContactItem(String contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              contact,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
        ],
      ),
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
}
