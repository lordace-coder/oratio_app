import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/ui/bright/modals/offering.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/bright/pages/create_event.dart';
import 'package:oratio_app/ui/bright/pages/withdrawal_modal.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/home.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  bool showBalance = false;

  void showComingSoon() {
    NotificationService.showInfo("Coming soon", duration: Durations.extralong4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        context,
        label: 'Parish Dashboard',
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                  child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.userNinja,
                    color: Colors.black54,
                  ),
                  Gap(5),
                  Text('Customer Support')
                ],
              )),
              const PopupMenuItem(
                  child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.question,
                    color: Colors.black54,
                  ),
                  Gap(5),
                  Text('Get Help')
                ],
              ))
            ],
          ),
        ],
      ),
      body: Container(
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
                  const Gap(20),
                  // body,
                  // * card to display details
                  SizedBox(
                    height: 109,
                    child: Container(
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
                                  onTap: () {
                                    context
                                        .pushNamed(RouteNames.transactionsPage);
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  showBalance ? '₦ 5000.00' : '*******',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) =>
                                            const WithdrawalModal());
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        'Request Withdrawal',
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
                  ),

                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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
                              text: 'Mass Requests',
                              onTap: () {
                                showComingSoon();
                              },
                            ),
                            DashboardButton(
                              icon: FontAwesomeIcons.church,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        const PrayerCommunityCreationPage()));
                              },
                              text: 'Create Community',
                            ),
                            // DashboardButton(
                            //   icon: FontAwesomeIcons.dropbox,
                            //   onTap: () {
                            //     // show modal with more options like communities,generate qr
                            //     // showDialog(context: context, builder: (ctx)=>);
                            //   },
                            //   text: 'More',
                            // ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Tooltip(
                                message:
                                    'View those that request your services as a priest',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.userGroup,
                                  text: 'Seeking Souls',
                                  onTap: () {
                                    showComingSoon();
                                  },
                                ),
                              ),
                              gap,
                              DashboardButton(
                                icon: FontAwesomeIcons.clock,
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) =>
                                          const CreateEventPage()));
                                },
                                text: 'Create Event',
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Tooltip(
                                message: 'View offerings',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.cashRegister,
                                  onTap: () {
                                    // showDialog(context: context, builder: (ctx)=>const OfferingGivingModal());
                                  },
                                  text: 'Offering\'s',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Tooltip(
                                message: 'Generate qr code for mass',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.qrcode,
                                  text: 'Generate Qr',
                                  onTap: showComingSoon,
                                ),
                              ),
                              gap,
                              Tooltip(
                                message: 'Hold a live mass',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.readme,
                                  text: 'Go Mass',
                                  onTap: () {
                                    showComingSoon();
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
                              'Recent Actions',
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
      ),
    );
  }
}
