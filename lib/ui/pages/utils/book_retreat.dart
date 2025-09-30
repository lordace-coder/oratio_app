// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/helpers/transaction_modal.dart';
import 'package:oratio_app/networkProvider/booking_requests.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/payment_proof.dart';
import 'package:pocketbase/pocketbase.dart';

class RetreatBookingPage extends StatefulWidget {
  const RetreatBookingPage(
      {super.key, required this.parishId, required this.parishName});
  final String parishId;
  final String parishName;
  @override
  State<RetreatBookingPage> createState() => _RetreatBookingPageState();
}

class _RetreatBookingPageState extends State<RetreatBookingPage> {
  List<DateTime> selectedDates = [];
  TimeOfDay? fromTime;
  TimeOfDay? finishTime;
  final _descriptionController = TextEditingController();
  String? donationId;
  bool isDonating = false;
  RecordModel? paymentProof;
  // Dummy data for parish name and leader's name

  Future<void> selectDates() async {
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(
      now.year,
      now.month + 1,
      now.day,
    );

    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: nextMonth,
    );

    if (dateRange != null) {
      setState(() {
        selectedDates = [];
        for (DateTime date = dateRange.start;
            date.isBefore(dateRange.end) ||
                date.isAtSameMomentAs(dateRange.end);
            date = date.add(const Duration(days: 1))) {
          selectedDates.add(date);
        }
      });
    }
  }

  Future<void> selectFromTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: fromTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        fromTime = time;
      });
    }
  }

  bool get _isDataValid {
    if (selectedDates.isEmpty) {
      NotificationService.showWarning("Select the dates first");
      return false;
    } else if (_descriptionController.text.isEmpty) {
      NotificationService.showWarning("Tell us the reason for the retreat.");
      return false;
    }
    return true;
  }

  void handleBookNow() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: createAppBar(
        context,
        label: 'Book Retreat',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildParishInfoCard(context),
                const Gap(16),
                _buildDateSelectionCard(context),
                const Gap(16),
                _buildDescriptionInput(context),
                const Gap(16),
                if (donationId == null)
                  buildGradientButton(
                      "Make Donation", FontAwesomeIcons.moneyBill, () async {
                    BuildContext? dialogContext;
                    final pb = getPocketBaseFromContext(context);
                    final user = pb.authStore.model as RecordModel;

                    try {
                      final RecordModel? payment =
                          await getPaymentProof(context);
                      if (payment == null) {
                        setState(() => isDonating = false);
                      } else {
                        showSuccess(context,
                            message: 'Proof of payment submitted succesfully');
                        paymentProof = payment;
                        setState(() => isDonating = false);
                      }
                      return;
                    } catch (e) {
                      setState(() => isDonating = false);
                      print([
                        (e as DioException).response,
                        e.requestOptions.data
                      ]);
                      showError(context, message: 'Error occurred $e');
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
                  }),
                const Gap(20),
                AnimatedOpacity(
                  duration: Durations.medium1,
                  opacity: paymentProof == null ? 0.3 : 1,
                  child: buildGradientButton(
                      "Complete Booking", FontAwesomeIcons.atom, () async {
                    if (paymentProof == null) {
                      return NotificationService.showInfo(
                          "Please make a donation for the retreat first");
                    }
                    // verify that all the required data has been entered before submitting
                    BuildContext? dialogContext;
                    if (_isDataValid) {
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
                                    Text('Processing booking...'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      // handle submission here
                      final pb = getPocketBaseFromContext(context);
                      try {
                        print(paymentProof?.id);

                        if (paymentProof == null) {
                          showError(context,
                              message: 'pleae reupload payment proof');
                          return;
                        }
                        await handleRetreatBooking(pb: pb, data: {
                          'payment': paymentProof?.id,
                          "user": getUser(context).id,
                          "startTime": selectedDates[0].toIso8601String(),
                          "endTime": selectedDates[1].toIso8601String(),
                          "description": _descriptionController.text.trim()
                        });
                        NotificationService.showSuccess(
                            "Retreat Booking completed. You will get a feedback with more details later on.",
                            duration: const Duration(seconds: 5));
                        if (dialogContext != null) {
                          Navigator.of(dialogContext!).pop();
                        }
                        context.goNamed(RouteNames.homePage);
                      } catch (e) {
                        if (dialogContext != null) {
                          Navigator.of(dialogContext!).pop();
                        }
                        NotificationService.showError(
                            "An error occurred while booking retreat");
                        print(['error occurred $e']);
                        rethrow;
                      }
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParishInfoCard(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.parishName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(8),
          FutureBuilder(future: <String>() async {
            try {
              final req = await pb
                  .collection("parish")
                  .getOne(widget.parishId, expand: "priest");
              return getFullName(req.expand['priest']!.first);
            } catch (e) {}
            return '';
          }(), builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else if (snapshot.data!.isEmpty) {
              return Container();
            }
            return Text(
              'Leader: ${snapshot.data}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(12),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter the reason for the retreat...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Select Dates',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(12),
          ElevatedButton.icon(
            onPressed: selectDates,
            icon: const Icon(FontAwesomeIcons.calendarAlt),
            label: Text(selectedDates.isEmpty
                ? 'Select Dates'
                : 'Selected ${selectedDates.length} Dates'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildPopupMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const Gap(12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class NoParishYet extends StatelessWidget {
  const NoParishYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.wineGlassEmpty,
            size: 32,
            color: Colors.grey[600],
          ),
          const Gap(16),
          Text(
            'Churches You Have Joined Will Be Displayed Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(RouteNames.parishpage),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(FontAwesomeIcons.church, size: 16),
            label: const Text(
              'Join Church',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildChurchItem(BuildContext context, RecordModel church,
    Function()? onTap, bool selected) {
  final pb = getPocketBaseFromContext(context);
  return GestureDetector(
    onTap: onTap,
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
                pb
                    .getFileUrl(church, church.getStringValue('image'))
                    .toString(),
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
            const Gap(10),
            TextButton(
                onPressed: onTap, child: Text(selected ? 'Selected' : 'Select'))
          ],
        ),
      ),
    ),
  );
}
