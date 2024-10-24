import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: createAppBar(context, label: 'Transaction Details', actions: [
        IconButton(
          onPressed: () {
            //contact customer support
          },
          icon: const Icon(FontAwesomeIcons.userTie),
        ),
      ]),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const Gap(20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 30),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Gap(20),
                  TransactionRow(
                    text: 'Transaction Type',
                    value: 'Mass Booking',
                  ),
                  TransactionRow(
                    text: 'Transaction Id',
                    value: '102901098912929192',
                  ),
                  TransactionRow(
                    text: 'Transaction Time',
                    value: 'Oct 10th,2024 12:12:24 PM',
                  ),
                  TransactionRow(
                    text: 'Transaction Type',
                    value: 'Mass Booking',
                  ),
                  TransactionRow(
                    text: 'Transaction Type',
                    value: 'Mass Booking',
                  ),
                ],
              ),
            ),

            // bottom buttons

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Share Receipt',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.text,
    required this.value,
  });

  final String text;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.black45),
          ),
          SelectableText(value)
        ],
      ),
    );
  }
}
