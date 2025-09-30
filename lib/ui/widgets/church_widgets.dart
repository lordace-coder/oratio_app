import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/helpers/transaction_modal.dart';
import 'package:oratio_app/networkProvider/booking_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/book_counselling.dart';
import 'package:pocketbase/pocketbase.dart';

class ChurchListTile extends StatelessWidget {
  const ChurchListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          context.pushNamed(RouteNames.parishlanding);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black45),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'St. Patrick ',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.locationPin,
                            size: 10,
                            color: AppColors.primary,
                          ),
                          const Gap(3),
                          Text(
                            '5th Ave. New York, NY',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDarkDim,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.gray),
                      child: const Center(
                          child: Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )),
                    ),
                  ),
                )
              ],
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final Function(String value) onSubmit;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.dimGray, borderRadius: BorderRadius.circular(5)),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmit,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: Colors.black54,
        ),
        controller: controller,
        decoration: const InputDecoration(
            hintStyle:
                TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
            border: InputBorder.none,
            hintText: 'Search for a church or Mass center',
            prefixIcon: Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Colors.black45,
              size: 17,
            )),
      ),
    );
  }
}

class DateItemButton extends StatelessWidget {
  const DateItemButton({
    super.key,
    required this.selected,
    required this.title,
    required this.date,
    required this.onTap,
  });

  final VoidCallback onTap;
  final bool selected;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontSize: 17),
            ),
            Text(
              date,
              style:
                  TextStyle(color: selected ? Colors.white60 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class MassTimeButton extends StatelessWidget {
  const MassTimeButton({
    super.key,
    required this.time,
    required this.mass,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final String mass;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                FontAwesomeIcons.clock,
                color: selected ? Colors.white : Colors.black,
              ),
              const Gap(5),
              Text(
                time,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
              Text(
                mass,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildChurchCard(BuildContext context, RecordModel church) {
  return GestureDetector(
    onTap: () {
      context.pushNamed(RouteNames.parishlanding, pathParameters: {
        'id': church.id,
      });
    },
    child: Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // Reduced margins
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8), // Reduced padding
        child: Row(
          children: [
            // Church image with error handling
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://via.placeholder.com/60', // Reduced size
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                // Handle image load errors
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.church, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    church.getStringValue('name').toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: Colors.grey[600]),
                      const Gap(2),
                      Expanded(
                        child: Text(
                          church.getStringValue('location'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  // Row(
                  //   children: [
                  //     _buildInfoChip(Icons.access_time, '5 min'),
                  //     const Gap(4),
                  //     _buildInfoChip(Icons.calendar_today, '4 masses'),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

AppBar createAppBar(BuildContext context,
    {required String label,
    List<Widget>? actions,
    Color? foregroundColor,
    Color? backgroundColor}) {
  return AppBar(
    leading: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: const Icon(FontAwesomeIcons.chevronLeft)),
    foregroundColor: foregroundColor ?? Colors.white,
    backgroundColor: backgroundColor ?? AppColors.primary,
    title: Text(label),
    actions: actions,
  );
}

void showGiveOptions(BuildContext context) async {
  final pb = context.read<PocketBaseServiceCubit>().state.pb;
  final user = pb.authStore.model as RecordModel;

  /*
  !AVAILABLE REASONS
  offering
  tithe
  seed
   */
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Give',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.xmark),
              ),
            ],
          ),
          const Gap(24),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.handHoldingDollar,
            label: 'Give Offering',
            description: 'Support your parish',
            onTap: () async {
              // Create a BuildContext that we can safely dispose later
              BuildContext? dialogContext;
              try {
                final parish = await showChurchSelect(context);
                if (parish == null) {
                  return NotificationService.showError(
                    'Cancelled Transaction',
                    duration: Durations.extralong4,
                  );
                }

                final amt = await showTransactionModal(
                  context,
                  TransactionDetail("Give",
                      handleTransaction: (context, data) {},
                      onChange: (val) {},
                      icon: const Icon(FontAwesomeIcons.cashRegister),
                      title: 'Give Offering',
                      detail: 'Support Your Parish'),
                );

                if (amt == null) {
                  return NotificationService.showError(
                    'Cancelled Transaction',
                    duration: Durations.extralong4,
                  );
                }

                // Show loading modal
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    dialogContext = context; // Store the dialog's context
                    return const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Processing offering...'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

                // Process the transaction
                final parsedAmt = int.tryParse(amt);
                if (parsedAmt == null) {
                  if (dialogContext != null) Navigator.pop(dialogContext!);
                  return showError(context, message: 'Invalid amount parsed');
                }

                if (parsedAmt >
                    double.tryParse((await getUserBalance(user.id, pb))
                        .replaceAll('₦', ''))!) {
                  if (dialogContext != null) Navigator.pop(dialogContext!);
                  return showError(context,
                      message:
                          'Insufficient balance \n please fund account and try again');
                }

                final donation = await handleDonation(
                    pb, {'amount': parsedAmt, 'userId': pb.authStore.model.id});

                await sendOffering(context, data: {
                  "user": user.id,
                  "donation": donation!['recordId'],
                  "parish": parish,
                  "reason": "offering",
                });

                // Dismiss loading modal after transaction completes
                if (dialogContext != null) Navigator.pop(dialogContext!);

                // Show success message
                NotificationService.showSuccess(
                  'Offering sent successfully',
                  duration: Durations.extralong4,
                );
              } catch (e) {
                // Dismiss loading modal if there's an error
                if (dialogContext != null) Navigator.pop(dialogContext!);
                showError(context,
                    message: 'An error occurred: transaction failed');
              }
            },
          ),
          const Gap(16),
          buildGiveOption(context,
              icon: FontAwesomeIcons.coins,
              label: 'Pay Tithes',
              description: '10% of your income', onTap: () async {
            // Create a BuildContext that we can safely dispose later
            BuildContext? dialogContext;
            try {
              final parish = await showChurchSelect(context);
              if (parish == null) {
                return NotificationService.showError(
                  'Cancelled Transaction',
                  duration: Durations.extralong4,
                );
              }

              final amt = await showTransactionModal(
                context,
                TransactionDetail("Give",
                    handleTransaction: (context, data) {},
                    onChange: (val) {},
                    icon: const Icon(FontAwesomeIcons.cashRegister),
                    title: 'Pay Your tithe',
                    detail: 'A tenth of thy wages'),
              );

              if (amt == null) {
                return NotificationService.showError(
                  'Cancelled Transaction',
                  duration: Durations.extralong4,
                );
              }

              // Show loading modal
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  dialogContext = context; // Store the dialog's context
                  return const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing transaction...'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

              // Process the transaction
              final parsedAmt = int.tryParse(amt);
              if (parsedAmt == null) {
                if (dialogContext != null) Navigator.pop(dialogContext!);
                return showError(context, message: 'Invalid amount parsed');
              }

              if (parsedAmt >
                  double.tryParse((await getUserBalance(user.id, pb))
                      .replaceAll('₦', ''))!) {
                if (dialogContext != null) Navigator.pop(dialogContext!);
                return showError(context,
                    message:
                        'Insufficient balance \n please fund account and try again');
              }

              final donation = await handleDonation(
                  pb, {'amount': parsedAmt, 'userId': pb.authStore.model.id});

              await sendOffering(context, data: {
                "user": user.id,
                "donation": donation!['recordId'],
                "parish": parish,
                "reason": "tithe",
              });

              // Dismiss loading modal after transaction completes
              if (dialogContext != null) Navigator.pop(dialogContext!);

              // Show success message
              NotificationService.showSuccess(
                'Tithe paid successfully',
                duration: Durations.extralong4,
              );
            } catch (e) {
              // Dismiss loading modal if there's an error
              if (dialogContext != null) Navigator.pop(dialogContext!);
              showError(context, message: 'An error occurred: ${e.toString()}');
            }
          }),
          const Gap(16),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.seedling,
            label: 'Special Seed',
            description: 'Give for a specific cause',
            onTap: () async {
              BuildContext? dialogContext;
              try {
                final parish = await showChurchSelect(context);
                if (parish == null) {
                  return NotificationService.showError(
                    'Cancelled Transaction',
                    duration: Durations.extralong4,
                  );
                }

                final amt = await showTransactionModal(
                  context,
                  TransactionDetail("Give",
                      handleTransaction: (context, data) {},
                      onChange: (val) {},
                      icon: const Icon(FontAwesomeIcons.cashRegister),
                      title: 'Special Seed',
                      detail: 'Give for'),
                );

                if (amt == null) {
                  return NotificationService.showError(
                    'Cancelled Transaction',
                    duration: Durations.extralong4,
                  );
                }

                // Show loading modal
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    dialogContext = context; // Store the dialog's context
                    return const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Processing Transaction...'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

                final parsedAmt = int.tryParse(amt);
                if (parsedAmt == null) {
                  if (dialogContext != null) Navigator.pop(dialogContext!);
                  return showError(context, message: 'Invalid amount parsed');
                }

                if (parsedAmt >
                    double.tryParse((await getUserBalance(user.id, pb))
                        .replaceAll('₦', ''))!) {
                  if (dialogContext != null) Navigator.pop(dialogContext!);
                  return showError(context,
                      message:
                          'Insufficient balance \n please fund account and try again');
                }

                final donation = await handleDonation(
                    pb, {'amount': parsedAmt, 'userId': pb.authStore.model.id});

                await sendOffering(context, data: {
                  "user": user.id,
                  "donation": donation!['recordId'],
                  "parish": parish,
                  "reason": "seed",
                });

                // Dismiss loading modal after transaction completes
                if (dialogContext != null) Navigator.pop(dialogContext!);

                // Show success message
                NotificationService.showSuccess(
                  'Seed sent successfully',
                  duration: Durations.extralong4,
                );
              } catch (e) {
                // Dismiss loading modal if there's an error
                if (dialogContext != null) Navigator.pop(dialogContext!);
                showError(context,
                    message: 'An error occurred: ${e.toString()}');
              }
            } // Create a BuildContext that we can safely dispose later

            ,
          ),
        ],
      ),
    ),
  );
}

Widget buildGiveOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String description,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            FontAwesomeIcons.chevronRight,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );
}

void showDoMoreOptions(BuildContext context,
    {bool showOfferingOption = false}) async {
  final pb = context.read<PocketBaseServiceCubit>().state.pb;
  final user = pb.authStore.model as RecordModel;

  /*
  !AVAILABLE REASONS
  offering
  tithe
  seed
   */
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Do More',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.xmark),
              ),
            ],
          ),
          const Gap(10),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.church,
            label: 'Book Retreat',
            description: '',
            onTap: () async {
              // Handle book retreat
              String? parishId = await showChurchSelect(context);
              await context.read<ProfileDataCubit>().getMyProfile();
              // allow user select desired parish
              if (parishId != null) {
                final profileState = context.read<ProfileDataCubit>().state;
                // get parish details from profile
                if (profileState is ProfileDataLoaded) {
                  final selectedParish =
                      (profileState).profile.parish.firstWhere((item) {
                    return item.id == parishId;
                  });
                  context.pushNamed(RouteNames.bookRetreat, pathParameters: {
                    "id": parishId,
                    "parishName": selectedParish.getStringValue("name"),
                  });
                }
                Navigator.of(context).pop();
              } else {
                NotificationService.showWarning(
                    "Parish for the retreat has to be selected first");
                Navigator.of(context).pop();
              }
            },
          ),
          const Gap(16),
          buildGiveOption(context,
              icon: FontAwesomeIcons.search,
              label: 'Seek Counselors',
              description: '', onTap: () {
            // Create a BuildContext that we can safely dispose later
            print("called");
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CounselorSelectionModal(),
            );
          }),
          const Gap(16),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.userMd,
            label: 'Book Appointment',
            description: 'Create an appointment with a Spiritual director.',
            onTap: () async {
              context.pushNamed(RouteNames.bookAppointment);
            },
          ),
        ],
      ),
    ),
  );
}
