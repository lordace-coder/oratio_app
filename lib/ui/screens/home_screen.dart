import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/home.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    super.key,
  });

  bool showBalance = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 15,
                      ),
                      Gap(8),
                      Text('Hi,Chibuike'),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onTap: () {},
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        style:
                                            TextStyle(color: AppColors.primary),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onTap: () {},
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        style:
                                            TextStyle(color: AppColors.primary),
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
                          onTap: () {},
                        ),
                        DashboardButton(
                          icon: FontAwesomeIcons.moneyBill,
                          onTap: () {},
                          text: 'Withdraw',
                        ),
                        DashboardButton(
                          icon: FontAwesomeIcons.church,
                          onTap: () {},
                          text: 'Join Parish',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  // ignore: prefer_const_constructors
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashboardButton(
                            icon: FontAwesomeIcons.book,
                            text: 'Communities',
                            onTap: () {},
                          ),
                          gap,
                          DashboardButton(
                            icon: FontAwesomeIcons.clock,
                            onTap: () {},
                            text: 'Schedules',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Tooltip(
                            message: 'Account Settings',
                            child: DashboardButton(
                              icon: FontAwesomeIcons.gear,
                              onTap: () {},
                              text: 'Account',
                            ),
                          ),
                          gap,
                          Tooltip(
                            message: 'Request Prayer\'s',
                            child: DashboardButton(
                              icon: FontAwesomeIcons.pray,
                              text: 'Prayer\'s',
                              onTap: () {},
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
                              onTap: () {},
                            ),
                          ),
                          gap,
                          Tooltip(
                            message: 'Daily Reading',
                            child: DashboardButton(
                              icon: FontAwesomeIcons.readme,
                              text: 'Reading',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const Gap(20),
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
                          onPressed: () {},
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
    );
  }
}
