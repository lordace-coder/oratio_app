// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/ui/pages/mass_booking_page.dart';

class TransactionModal extends StatelessWidget {
  final TextEditingController controller;
  final Function(BuildContext, int) handleTransaction;

  ///function to be called when there is a change in the input,
  ///
  ///you can handle validation and confirm if user balance is sufficient
  final Function(String) onChange;
  final Widget icon;
  final String title;
  final String detail;

  ///text for the submit button
  final String actionLabel;
  const TransactionModal({
    super.key,
    required this.controller,
    required this.handleTransaction,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onChange,
    required this.actionLabel,
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
              child: icon,
            ),
            const Gap(16),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),

            // Subtitle
            Text(
              detail,
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
                onChanged: onChange,
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
                  handleTransaction(context, amt);
                  Navigator.of(context).pop();
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
                child: Text(
                  actionLabel,
                  style: const TextStyle(
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

Future<String?>? showTransactionModal(
    BuildContext context, TransactionDetail detail) async {
  String? amt;
  await showDialog(
      context: context,
      builder: (_) => TransactionModal(
            controller: TextEditingController(),
            handleTransaction: (context, cashAmt) {
              amt = cashAmt.toString();
            },
            icon: detail.icon,
            actionLabel: detail.actionLabel,
            detail: detail.detail,
            onChange: detail.onChange,
            title: detail.title,
          ));
  return amt;
}

Future<String?>? showChurchSelect(BuildContext context) async {
  String? church;
  await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: BlocConsumer<ProfileDataCubit, ProfileDataState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is ProfileDataLoaded) {
                if (state.profile.parish.isNotEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(FontAwesomeIcons.church),
                      ),
                      const Gap(16),

                      // Title
                      Text(
                        "Your Parish",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Gap(8),

                      // Subtitle
                      Text(
                        "A list of parish you attend",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const Gap(24),
                      ...state.profile.parish.map(
                        (i) => buildChurchItem(context, i, () async {
                          church = i.id;
                          await Future.delayed(Durations.short1);
                          NotificationService.showInfo(
                            "Parish Selected",
                            duration: Durations.extralong1,
                          );
                          Navigator.pop(context);
                        }, false),
                      )
                    ],
                  );
                }
              }
              context.read<ProfileDataCubit>().getMyProfile();
              return const NoParishYet();
            },
          ),
        );
      });
  return church;
}

class TransactionDetail {
  final Function(BuildContext, int) handleTransaction;

  final Function(String) onChange;
  final Widget icon;
  final String title;
  final String detail;
  final String actionLabel;

  TransactionDetail(
    this.actionLabel, {
    required this.handleTransaction,
    required this.onChange,
    required this.icon,
    required this.title,
    required this.detail,
  });
}
