import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
                        keyboardType: TextInputType.number,
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
                        print('invalid amount data');
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
