import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.gray,
        body: SafeArea(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {},
            child: ListView(
              padding: EdgeInsets.zero,
              // appbar
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.chevronLeft,
                                size: 18,
                              ),
                              Gap(30),
                              Text(
                                'Profile',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          PopupMenuButton(
                            padding: const EdgeInsets.all(0),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  onTap: () {
                                    context.pushNamed(RouteNames.login);
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.doorOpen,
                                        color: Colors.black54,
                                      ),
                                      Gap(7),
                                      Text(
                                        'LogOut',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                      const Gap(30),
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 30,
                      ),
                      const Gap(10),
                      const Text("Ahmed Christian"),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const Gap(7),
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              'Recent Activity',
                              style: TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
                const Gap(20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Parish Your Attending'),
                      const Gap(10),
                      ChurchProfileItem(
                        label: 'St John\'s Parish',
                        onTap: () {},
                        onTapLabel: 'remove',
                      ),
                      ChurchProfileItem(
                        label: 'St John\'s Parish',
                        onTap: () {},
                        onTapLabel: 'remove',
                      ),
                      ChurchProfileItem(
                        label: 'St John\'s Parish',
                        onTap: () {},
                        onTapLabel: 'remove',
                      ),
                    ],
                  ),
                ),
                const Gap(20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contact Information'),
                      const Gap(10),
                      ChurchProfileItem(
                        label: '0901234567809',
                        onTap: () {},
                        onTapLabel: 'edit',
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Add Contact Information',
                          style: TextStyle(
                            color: AppColors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.blue,
                          ),
                        ),
                      ),
                      const Gap(10),
                    ],
                  ),
                ),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Language'),
                      const Gap(10),
                      ChurchProfileItem(
                        label: 'English -Us',
                        onTap: () {},
                        onTapLabel: 'Choose Language',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class ChurchProfileItem extends StatelessWidget {
  const ChurchProfileItem({
    super.key,
    required this.label,
    required this.onTapLabel,
    required this.onTap,
  });

  final String label;
  final String onTapLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('St John\'s parish'),
          GestureDetector(
            onTap: () {},
            child: Text(
              'remove',
              style: TextStyle(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }
}
