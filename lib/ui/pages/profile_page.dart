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
            children: [
              // Top section with avatar, username, and buttons
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          const Color.fromARGB(255, 35, 1, 86)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 16,
                    child: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        FontAwesomeIcons.chevronLeft,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 40,
                          child: Icon(
                            FontAwesomeIcons.userAstronaut,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const Gap(10),
                        const Text(
                          "Ahmed Christian",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton("Edit Profile", Icons.edit, () {
                              // Handle profile edit
                            }),
                            const Gap(10),
                            _buildActionButton("Recent Activity", Icons.history,
                                () {
                              // Handle recent activity
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Fields for Parish, Contact Information, and Language
              _buildSection("Parish You're Attending", [
                _buildItem("St John's Parish", "remove", () {}),
                _buildItem("St Mary's Parish", "remove", () {}),
                _buildItem("St Peter's Parish", "remove", () {}),
              ]),
              _buildSection("Contact Information", [
                _buildItem("09012345678", "edit", () {}),
                GestureDetector(
                  onTap: () {
                    // Handle add contact
                  },
                  child: Text(
                    'Add Contact Information',
                    style: TextStyle(
                      color: AppColors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.blue,
                    ),
                  ),
                ),
              ]),
              _buildSection("Select Language", [
                _buildItem("English - US", "Choose Language", () {}),
              ]),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.pushNamed(RouteNames.login);
                  },
                  child: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.pushNamed(RouteNames.login);
                  },
                  child: const Text(
                    "Customer Service",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const Gap(5),
            Text(
              text,
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Gap(10),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String actionLabel, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: TextStyle(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
