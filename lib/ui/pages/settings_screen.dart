import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/url_launcher.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/user_settings_service.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:confirm_dialog/confirm_dialog.dart' as dialogs;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late PocketBase pocketBase;

  @override
  void initState() {
    super.initState();
    pocketBase = context.read<PocketBaseServiceCubit>().state.pb;
  }

  String? getAvatar(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    final avatarUrl = pb
        .getFileUrl(pocketBase.authStore.model,
            pocketBase.authStore.model.getStringValue('avatar'))
        .toString();
    if (avatarUrl.isEmpty) {
      return null;
    }
    return avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    final user = pocketBase.authStore.model as RecordModel;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Color(0xff202ADA),
            // Color.fromARGB(255, 16, 21, 105),
            Color.fromARGB(255, 242, 242, 242),
            Colors.white
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
                // Profile Section
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          // gradient: LinearGradient(
                          //   colors: [Colors.blue[400]!, Colors.white],
                          // ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: getAvatar(context) != null
                              ? CachedNetworkImageProvider(getAvatar(context)!)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getFullName(user),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.getStringValue("email"),
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // IconButton(
                      //   onPressed: () {
                      //     context.pushNamed(RouteNames.editprofile);
                      //   },
                      //   icon: const Icon(Icons.edit_outlined,
                      //       color: Colors.white),
                      // ),
                    ],
                  ),
                ),

                // Settings List
                Container(
                  margin: const EdgeInsets.only(top: 12, left: 24, right: 24),
                  child: const Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                ..._buildSettingsItems(),

                _buildSecureModeToggle(),

                const SizedBox(height: 24), // Bottom padding

                // Footer
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Powered by LordAce 2024',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required List<Color> gradient,
      required Function() onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A35E8).withOpacity(0.15),
            const Color(0xFF1C24BD).withOpacity(0.25),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF202ADA).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap.call();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsItems() {
    final items = [
      _SettingsItem(
        icon: Icons.person_outline,
        title: 'Account Settings',
        subtitle: 'Update your profile details',
        iconGradient: [Colors.purple[400]!, Colors.pink[400]!],
        onTap: () {
          context.pushNamed(RouteNames.editprofile);
        },
      ),
      _SettingsItem(
        icon: Icons.block,
        title: 'Blocked Users',
        subtitle: 'Manage blocked users',
        iconGradient: [Colors.red[400]!, Colors.deepOrange[400]!],
        onTap: () {
          context.pushNamed(RouteNames.blockedUsers);
        },
      ),
      // _SettingsItem(
      //   icon: Icons.palette_outlined,
      //   title: 'Appearance',
      //   subtitle: 'Customize your app theme',
      //   iconGradient: [Colors.blue[400]!, Colors.cyan[400]!],
      //   onTap: () async {
      //     final pref = await SharedPreferences.getInstance();
      //     final settings = UserSettings(pref);
      //     dialogs
      //         .confirm(context,
      //             title: const Text("Change Theme"),
      //             content: const Text("Do you want to change the theme?"),
      //             textOK: const Text("Yes"),
      //             textCancel: const Text("No"))
      //         .then((value) {
      //       if (value) {
      //         settings.updateAppSettings(AppSettings()..isDarkMode = true);
      //       }
      //     });
      //   },
      // ),

      _SettingsItem(
        icon: Icons.language_outlined,
        title: 'Language',
        subtitle: 'Change app language',
        iconGradient: [Colors.orange[400]!, Colors.amber[400]!],
        onTap: () {
          NotificationService.showInfo('Coming soon');
        },
      ),
      _SettingsItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help from our team',
        iconGradient: [Colors.teal[400]!, Colors.green[400]!],
        onTap: () {
          openWhatsApp(
              phoneNumber: '+2347032096095', message: 'Customer support ');
        },
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: 'App Licences',
        subtitle: 'View open-source licences',
        iconGradient: [Colors.indigo[400]!, Colors.blue[400]!],
        onTap: () {
          showLicensePage(context: context);
        },
      ),
      _SettingsItem(
        icon: Icons.description_outlined,
        title: 'Terms and Conditions',
        subtitle: 'Read our terms and conditions',
        iconGradient: [Colors.red[400]!, Colors.orange[400]!],
        onTap: () {
          openTermsUrl(context);
        },
      ),
      _SettingsItem(
        icon: Icons.privacy_tip_outlined,
        title: 'App Privacy Policy',
        subtitle: 'Read our privacy policy',
        iconGradient: [Colors.green[400]!, Colors.teal[400]!],
        onTap: () {
          openPolicyUrl(context);
        },
      ),
    ];

    return items.map((item) => _buildSettingsItem(item)).toList();
  }

  Widget _buildSettingsItem(_SettingsItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[850]!.withOpacity(0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: item.onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: item.iconGradient),
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSecureModeToggle() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final prefs = snapshot.data!;
        final settings = UserSettings(prefs);
        final isSecureMode = settings.appSettings.secureMode;

        return SwitchListTile(
          title: const Text('Secure Mode'),
          subtitle: const Text('Enable or disable secure mode'),
          value: isSecureMode,
          onChanged: (value) async {
            final confirm = await dialogs.confirm(
              context,
              title: const Text("Confirm Action"),
              content: const Text(
                  "Are you sure you want to change the secure mode setting? You will be held responsible if something happens."),
              textOK: const Text("Yes"),
              textCancel: const Text("No"),
            );
            if (confirm) {
              setState(() {
                if (value) {
                  settings.turnOnSecureMode();
                  AppLock.of(context)?.enable();
                } else {
                  settings.turnOffSecureMode();
                  AppLock.of(context)?.disable();
                }
              });
            }
          },
        );
      },
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Function() onTap;
  final List<Color> iconGradient;

  _SettingsItem({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconGradient,
  });
}
