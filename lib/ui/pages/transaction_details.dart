import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/ui/themes.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Contact customer support
                     openWhatsApp(
                  phoneNumber: '+2347032096095',
                  message: 'Im looking for customer support');
                              
            },
            icon: const Icon(
              FontAwesomeIcons.headset,
            ),
          ),
        ],
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Gap(20),
                // Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 48,
                      ),
                      Gap(8),
                      Text(
                        'Payment Successful',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(8),
                      Text(
                        '₹ 500.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                // Receipt Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(16),
                      const TransactionRow(
                        text: 'Transaction Type',
                        value: 'Mass Booking',
                        icon: Icons.category,
                      ),
                      const TransactionRow(
                        text: 'Transaction ID',
                        value: '102901098912929192',
                        icon: Icons.receipt_long,
                      ),
                      const TransactionRow(
                        text: 'Date & Time',
                        value: 'Oct 10th, 2024 12:12:24 PM',
                        icon: Icons.access_time,
                      ),
                      const TransactionRow(
                        text: 'Payment Method',
                        value: 'Credit Card (**** 1234)',
                        icon: Icons.credit_card,
                      ),
                      const TransactionRow(
                        text: 'Booking For',
                        value: 'Sunday Mass',
                        icon: Icons.church,
                      ),
                      const TransactionRow(
                        text: 'Number of People',
                        value: '2',
                        icon: Icons.people,
                      ),
                      const TransactionRow(
                        text: 'Status',
                        value: 'Confirmed',
                        icon: Icons.check_circle,
                        valueColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text(
                          'Share Receipt',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const Gap(12),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      icon: Icon(
                        Icons.download,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.text,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String text;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Gap(8),
          SelectableText(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
