// import 'package:ade_flutterwave_working_version/core/ade_flutterwave.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/custom_ads.dart';
import 'package:oratio_app/ui/widgets/home.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showBalance = false;

  final WebViewController controller = WebViewController();

  final _pageController = PageController();
  late StreamController streamController;
  bool isPriest = true;
  bool animate = false;
  Stream animatePageView() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 6));
      await _pageController.animateToPage(2,
          duration: Durations.medium3, curve: Curves.bounceIn);
      await Future.delayed(const Duration(seconds: 6));
      await _pageController.animateToPage(0,
          duration: Durations.medium3, curve: Curves.bounceIn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (isPriest && animate) {
      streamController = StreamController();
      streamController.addStream(animatePageView());
      streamController.stream.listen(null);
    }
  }

  @override
  void dispose() {
    if (isPriest && animate) {
      streamController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.grey.withOpacity(0.5), // Adjust opacity here
              BlendMode.darken, // Choose how to blend the color
            ),
            image: Image.asset('assets/images/wallet_bg.jpeg').image),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: RefreshIndicator.adaptive(
            color: AppColors.primary,
            onRefresh: () async {
              await Future.delayed(Durations.extralong4);
            },
            child: ListView(
              children: [
                // app bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteNames.profile);
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 15,
                          ),
                        ),
                        const Gap(8),
                        const Text('Hi,Chibuike'),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        context.pushNamed(RouteNames.notifications);
                      },
                      icon: const Icon(
                        FontAwesomeIcons.bell,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      enableFeedback: true,
                      tooltip: 'notifications',
                    ),
                  ],
                ),
                // body
                // * card to display details
                SizedBox(
                  height: 109,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.primary,
                        ),
                        child: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Available Balance',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const Gap(5),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showBalance = !showBalance;
                                          });
                                        },
                                        child: Icon(
                                          showBalance
                                              ? FontAwesomeIcons.eye
                                              : FontAwesomeIcons.eyeSlash,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                          RouteNames.transactionsPage);
                                    },
                                    child: const Text(
                                      'Transactions >',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              // * balance
                              const Gap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    showBalance ? '₦ 5000.00' : '*******',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      collectPayment(context);
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          'Fund Account',
                                          style: TextStyle(
                                              color: AppColors.primary),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                      // * CHURCH DETAILS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.primary,
                        ),
                        child: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Available Balance',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const Gap(5),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showBalance = !showBalance;
                                          });
                                        },
                                        child: Icon(
                                          showBalance
                                              ? FontAwesomeIcons.eye
                                              : FontAwesomeIcons.eyeSlash,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                          RouteNames.transactionsPage);
                                    },
                                    child: const Text(
                                      'Transactions >',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              // * balance
                              const Gap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    showBalance ? '₦ 5000.00' : '*******',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          'Fund Account',
                                          style: TextStyle(
                                              color: AppColors.primary),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const Gap(20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashboardButton(
                            icon: FontAwesomeIcons.book,
                            text: 'Book Mass',
                            onTap: () {
                              context.pushNamed(RouteNames.mass);
                            },
                          ),
                          if (isPriest)
                            DashboardButton(
                              icon: FontAwesomeIcons.desktop,
                              onTap: () {
                                context.pushNamed(RouteNames.dashboard);
                              },
                              text: 'Dashboard',
                            ),
                          DashboardButton(
                            icon: FontAwesomeIcons.church,
                            onTap: () {
                              context.pushNamed(RouteNames.parishpage);
                            },
                            text: 'Join Parish',
                          ),
                          DashboardButton(
                            icon: FontAwesomeIcons.dropbox,
                            onTap: () {
                              // show modal with more options like give offering ,tithes
                              showAdaptiveDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                        height: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      context.pop();
                                                    },
                                                    icon: const Icon(
                                                        FontAwesomeIcons
                                                            .close)),
                                              ],
                                            ),
                                            dashboardModalOption(
                                                label: 'Give Offering',
                                                onTap: () {}),
                                            dashboardModalOption(
                                                label: 'Give Offering',
                                                onTap: () {}),
                                            dashboardModalOption(
                                                label: 'Give Offering',
                                                onTap: () {}),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            text: 'More',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),
                Builder(builder: (context) {
                  const gap = Gap(16); //* GAP SPACE FOR ITEMS
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    // ignore: prefer_const_constructors
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DashboardButton(
                              icon: FontAwesomeIcons.book,
                              text: 'Communities',
                              onTap: () {
                                context.pushNamed(RouteNames.communitypage);
                              },
                            ),
                            gap,
                            DashboardButton(
                              icon: FontAwesomeIcons.clock,
                              onTap: () {
                                context.pushNamed(RouteNames.schedule);
                              },
                              text: 'Schedules',
                            ),
                            gap,
                            DashboardButton(
                              icon: FontAwesomeIcons.gear,
                              onTap: () {
                                context.pushNamed(RouteNames.settingsPage);
                              },
                              text: 'Settings',
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Tooltip(
                              message: 'Account Settings',
                              child: DashboardButton(
                                icon: FontAwesomeIcons.solidUser,
                                onTap: () {
                                  context.pushNamed(RouteNames.profile);
                                },
                                text: 'Profile',
                              ),
                            ),
                            gap,
                            Tooltip(
                              message: 'Request Prayer\'s',
                              child: DashboardButton(
                                icon: FontAwesomeIcons.pray,
                                text: 'Prayer\'s',
                                onTap: () {
                                  context.pushNamed(RouteNames.prayerPage);
                                },
                              ),
                            ),
                            gap,
                            Tooltip(
                              message: 'Find friends and family',
                              child: DashboardButton(
                                icon: FontAwesomeIcons.userPlus,
                                text: 'Connect',
                                onTap: () {
                                  context.pushNamed(RouteNames.connect);
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tooltip(
                              message: 'Scan qr code for mass',
                              child: DashboardButton(
                                icon: FontAwesomeIcons.qrcode,
                                text: 'Scan Qr',
                                onTap: () {
                                  context.pushNamed(RouteNames.scanQr);
                                },
                              ),
                            ),
                            gap,
                            Tooltip(
                              message: 'Daily Reading',
                              child: DashboardButton(
                                icon: FontAwesomeIcons.readme,
                                text: 'Reading',
                                onTap: () {
                                  context.pushNamed(RouteNames.readingPage);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const Gap(20),
                // CustomBannerAd(
                //     buttonColor: Colors.white, onTap: () {}, label: 'join now'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transactions',
                            style: TextStyle(fontSize: 17),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushNamed(RouteNames.transactionsPage);
                            },
                            child: const Text('see more..'),
                          )
                        ],
                      ),
                      const TransactionItem(),
                      const TransactionItem(),
                      const TransactionItem(),
                      const TransactionItem(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardModalOption(
      {required String label, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Text(label),
            ],
          ),
          const Divider(),
          const Gap(6)
        ],
      ),
    );
  }
}
