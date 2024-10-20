import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
          label: 'Transactions',
          foregroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          actions: [
            GestureDetector(
              onTap: () {
                // TODO handle download
              },
              child: Text(
                'Download',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
            const Gap(10),
          ]),
      body: const SafeArea(
          child: Column(
        children: [],
      )),
    );
  }
}
