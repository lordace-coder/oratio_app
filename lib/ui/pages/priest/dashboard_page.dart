import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/home.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  bool showBalance = false;

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
                                  onTap: () {},
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
                              onTap: () {},
                            ),
                            DashboardButton(
                              icon: FontAwesomeIcons.church,
                              onTap: () {},
                              text: 'Create Community',
                            ),
                            DashboardButton(
                              icon: FontAwesomeIcons.dropbox,
                              onTap: () {
                                // show modal with more options like communities,generate qr
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
                                  onTap: () {},
                                ),
                              ),
                              gap,
                              DashboardButton(
                                icon: FontAwesomeIcons.clock,
                                onTap: () {},
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
                                  onTap: () {},
                                  text: 'Offering\'s',
                                ),
                              ),
                              gap,
                              Tooltip(
                                message: 'Request Prayer\'s',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.pray,
                                  text: 'Confessions',
                                  onTap: () {},
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
                                  onTap: () {},
                                ),
                              ),
                              gap,
                              Tooltip(
                                message: 'Hold a live mass',
                                child: DashboardButton(
                                  icon: FontAwesomeIcons.readme,
                                  text: 'Go Mass',
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
