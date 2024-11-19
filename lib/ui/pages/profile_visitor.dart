import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class ProfileVisitorPage extends StatelessWidget {
  const ProfileVisitorPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    context.read<ProfileDataCubit>().visitProfile(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await context.read<ProfileDataCubit>().visitProfile(id);
        },
        child: BlocConsumer<ProfileDataCubit, ProfileDataState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileDataLoading || state is ProfileDataInitial) {
              return Container(
                child: const Text('loading'),
              );
            }
            if (state is ProfileDataLoaded) {
              final data = state.guestProfile;
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
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Color(0xFF8B80FF),
                                    child: Icon(
                                      FontAwesomeIcons.userAstronaut,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Text(
                                  getFullName(data!.user),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  data.user.getStringValue('username'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Gap(12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildActionButton("Connect",
                                        FontAwesomeIcons.penToSquare, () {}),
                                    const Gap(16),
                                    _buildActionButton(
                                        "Activity",
                                        FontAwesomeIcons.clockRotateLeft,
                                        () {}),
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
                    child: Column(
                      children: [
                        _buildSection(
                          "Parish You're Attending",
                          FontAwesomeIcons.church,
                          [
                            ...data.parish.map((item) =>
                                _buildParishItem(item.getStringValue('name')))
                          ],
                        ),
                        _buildSection(
                          "Contact Information",
                          FontAwesomeIcons.addressBook,
                          [
                            _buildContactItem("09012345678"),
                            _buildAddButton("Add Contact Information"),
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
                                      phoneNumber: '+2349061299286',
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
                                () {
                                  context
                                      .read<PocketBaseServiceCubit>()
                                      .state
                                      .pb
                                      .authStore
                                      .clear();
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

            return Container(
              child: const Text('data'),
            );

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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildParishItem(String name) {
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
          TextButton(
            onPressed: () {},
            child: const Text(
              "Remove",
              style: TextStyle(
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
          TextButton(
            onPressed: () {},
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
          onPressed: () {},
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
}
