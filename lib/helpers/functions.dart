import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

void handleAccountFunding(
    BuildContext context, int amount, String email) async {
  Uri uri = Uri.parse(
      'https://bookmass.pythonanywhere.com/payment-page/$email/$amount');

  // launch url to payment inside the app
  if (await canLaunchUrl(uri)) {
    launchUrl(uri, mode: LaunchMode.inAppWebView);
  }
}

void collectPayment(BuildContext context) async {
  TextEditingController controller = TextEditingController();
  String email = 'lordyacey@gmail.com';

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
                    Navigator.of(context).pop();
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
                    handleAccountFunding(context, amt, email);
                  },
                  child: const Text('Fund Account'),
                ),
              ],
            )
          ],
        );
      });
}
