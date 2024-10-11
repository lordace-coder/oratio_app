// import 'package:ade_flutterwave_working_version/core/ade_flutterwave.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/home.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    super.key,
  });

  bool showBalance = false;

  void collectPayment(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      const Text('Type in Amount'),
                      const Gap(20),
                      TextField(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        return;
                      }
                      var amt = int.tryParse(controller.text.trim());
                      if (amt == null) {
                        // !tell user that amount is invalid
                        return;
                      }
                      var data = {
                        'amount': amt,
                        'email': 'lordyacey@gmail.com',
                        'phone': '09061299286',
                        'name': 'cole Gambit',
                        'payment_options': 'card, banktransfer, ussd',
                        'title': 'Flutterwave payment',
                        'currency': "NGN",
                        'tx_ref':
                            "AdeFlutterwave-${DateTime.now().millisecondsSinceEpoch}",
                        'icon':
                            "https://www.aqskill.com/wp-content/uploads/2020/05/logo-pde.png",
                        'public_key':
                            "FLWPUBK_TEST-a8ea0942834eb8fa157c3cc14361ec03-X",
                        'sk_key':
                            'FLWSECK_TEST-9a270817bf5f18ecfd35df938b4d2536-X'
                      };

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AdeFlutterWavePay(data),
                      //   ),
                      // ).then((response) {
                      //   //response is the response from the payment
                      //   print('response from flutter wave ==  $response');
                      // });
                    },
                    child: const Text('Fund Account'),
                  ),
                ],
              )
            ],
          );
        });
  }

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
                          onTap: () {
                            context.pushNamed(RouteNames.mass);
                          },
                        ),
                        DashboardButton(
                          icon: FontAwesomeIcons.moneyBill,
                          onTap: () {},
                          text: 'Withdraw',
                        ),
                        DashboardButton(
                          icon: FontAwesomeIcons.church,
                          onTap: () {
                            context.pushNamed(RouteNames.parishpage);
                          },
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
                            onTap: () {
                              context.pushNamed(RouteNames.communitypage);
                            },
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
                              onTap: () {
                                context.pushNamed(RouteNames.profile);
                              },
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
