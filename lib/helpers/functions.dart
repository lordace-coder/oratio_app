import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/networkProvider/paystack_payment.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

void handleAccountFunding(
    BuildContext context, int amount, String email) async {
  final orderId = email + DateTime.now().toIso8601String();
  await PaystackPaymentService(context.read<PocketBaseServiceCubit>().state.pb)
      .makePayment(
          email: email,
          amount: amount.ceilToDouble(),
          context: context,
          orderId: orderId,
          onSuccess: () {});
}

Future<void> collectPayment(BuildContext context) async {
  TextEditingController controller = TextEditingController();
  String email = (context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .authStore
          .model as RecordModel)
      .getStringValue('email');

  showDialog(
    context: context,
    builder: (context) => FundingModal(
      controller: controller,
      email: email,
      handleAccountFunding: handleAccountFunding,
    ),
  );
}

class FundingModal extends StatelessWidget {
  final TextEditingController controller;
  final String email;
  final Function(BuildContext, int, String) handleAccountFunding;

  const FundingModal({
    super.key,
    required this.controller,
    required this.email,
    required this.handleAccountFunding,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Gap(16),

            // Title
            Text(
              'Fund Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),

            // Subtitle
            Text(
              'Enter the amount you\'d like to add',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const Gap(24),

            // Amount Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: '0.00',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Action Buttons
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(8),
              // Fund Account Button
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter an amount'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  var amt = int.tryParse(controller.text.trim());
                  if (amt == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  handleAccountFunding(context, amt, email);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Fund Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void openWhatsApp(
    {required String phoneNumber, required String message}) async {
  final url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

class PaymentModal extends StatelessWidget {
  final TextEditingController controller;
  final String email;
  final Function(BuildContext, int, String) handlePayment;

  const PaymentModal({
    super.key,
    required this.controller,
    required this.email,
    required this.handlePayment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 32,
                color: Colors.greenAccent,
              ),
            ),
            const Gap(16),

            // Title
            Text(
              'PAYment title',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),

            // Subtitle
            Text(
              'Enter the amount you\'d like to add',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const Gap(24),
            const Row(
              children: [Text('Available Balance'), Text('balance')],
            ),
            // Amount Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: '0.00',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Action Buttons
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(8),
              // Fund Account Button
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter an amount'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  var amt = int.tryParse(controller.text.trim());
                  if (amt == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  handlePayment(context, amt, email);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'action title',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatDateTimeToHoursAgo(DateTime dateTime) {
  final now = DateTime.now().toLocal();
  final difference = now.difference(dateTime.toLocal());

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else {
    return DateFormat('d MMM yyyy').add_jm().format(dateTime);
  }
}

void openProfile(BuildContext context, String userId) {
  final currentUser = context
      .read<PocketBaseServiceCubit>()
      .state
      .pb
      .authStore
      .model
      .id as String;
  if (currentUser == userId) {
    context.pushNamed(RouteNames.profile);
    return;
  }
  context
      .pushNamed(RouteNames.profilepagevisitor, pathParameters: {'id': userId});
}

void openCommunity(BuildContext context, String id) {
  context.pushNamed(RouteNames.communityDetailPage,
      pathParameters: {'community': id});
}

void openPostDetail(BuildContext context, String id) {
  context.pushNamed(RouteNames.postDetailPage, pathParameters: {'post': id});
}

void editProfile(BuildContext context, String id) {
  context.pushNamed(RouteNames.editprofile, pathParameters: {'id': id});
}

void openParish(BuildContext context, String id) {
  context.pushNamed(RouteNames.parishlanding, pathParameters: {'id': id});
}




