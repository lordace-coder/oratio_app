import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/booking_bloc/state.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/helpers/transaction_modal.dart';
import 'package:oratio_app/networkProvider/booking_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/pages/pages.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';
import 'package:pocketbase/pocketbase.dart';

class MassBookBottomSheet extends StatefulWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final ScrollController scrollController;
  final MassBookingData data;

  const MassBookBottomSheet({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scrollController,
    required this.data,
  });

  @override
  State<MassBookBottomSheet> createState() => _MassBookBottomSheetState();
}

class _MassBookBottomSheetState extends State<MassBookBottomSheet> {
  String? donation;

  final TextEditingController intention = TextEditingController();

  final TextEditingController attendees = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),
          const Text(
            'Book Mass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          _buildWarningBox(),
          const Gap(20),
          _buildTextField(
            controller: intention,
            label: 'Intention',
            hint: 'Describe the intention why you are booking the mass',
          ),
          const Gap(16),
          _buildTextField(
            controller: attendees,
            label: 'Names of attendees',
            hint: 'Person for whom the mass is being offered',
          ),
          const Gap(24),
          if (donation != null) _buildSuccessMessage(),
          const Gap(20),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            color: AppColors.warning,
            size: 16,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'Please read carefully before answering',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFieldd(
        inputTextStyle: const TextStyle(color: Colors.black),
        labeltext: label,
        labelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        hintText: hint,
        controller: controller,
        isPassword: false,
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.solidCircleCheck,
            color: AppColors.green,
            size: 16,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'God bless you for that gracious donation',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    return Column(
      children: [
        FutureBuilder<String>(
            future: getUserBalance(
              pb.authStore.model.id,
              pb,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SubmitButtonV1(
                ontap: () async {
                  try {
                    final amt = await showTransactionModal(
                        context,
                        TransactionDetail("Donate",
                            handleTransaction: (context, data) {},
                            onChange: (val) {},
                            icon: const Icon(FontAwesomeIcons.cashRegister),
                            title: 'Donate',
                            detail: 'Make a donation for the mass'));
                    // validate amount before creating donation
                    final parsedAmt = double.tryParse('$amt');
                    if (parsedAmt == null) {
                      return showError(context,
                          message: 'Invalid amount entered');
                    }
                    // check for sufficient balance
                    if (parsedAmt >
                        double.tryParse(
                            '${snapshot.data}'.replaceAll('₦', ''))!) {
                      return showError(context,
                          message:
                              'Insufficient balance \n please fund account and try again');
                    }
                    if (parsedAmt < 200) {
                      return showError(context,
                          message: 'Donation amount cant be below ₦200');
                    }
                    final res = await handleDonation(pb,
                        {'amount': parsedAmt, 'userId': pb.authStore.model.id});
                    if (res == null) {
                      throw Exception(['Invalid donation data']);
                    }
                    setState(() {
                      donation = res['recordId'];
                    });
                    showSuccess(context,
                        message: 'You have succesfully donated ₦$parsedAmt');
                    return;
                  } catch (e) {
                    print(
                        [(e as DioException).response, e.requestOptions.data]);
                    return showError(context, message: 'Error occured $e');
                  }
                },
                radius: 12,
                backgroundcolor: AppColors.primary,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.handHoldingHeart,
                        color: Colors.white,
                        size: 16,
                      ),
                      Gap(8),
                      Text(
                        'Donate Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        const Gap(12),
        SubmitButtonV1(
          ontap: () async {
            final userId = context
                .read<PocketBaseServiceCubit>()
                .state
                .pb
                .authStore
                .model
                .id;
            if (donation != null) {
              // validate form fields
              if (intention.text.isEmpty) {
                return showError(context,
                    message: 'Mass Intention cant be empty');
              }
              if (attendees.text.isEmpty) {
                return showError(context, message: 'Add at least one attendee');
              }
              // form is valid
              print({
                "time": widget.data.getDateTime(),
                "parish": widget.data.selectedChurch.id,
                "intention": intention.text.trim(),
                "attendees": attendees.text.trim(),
                "user": userId,
                "donation": donation,
              });
              try {
                final res = await pb.collection("mass_booking").create(body: {
                  "time": widget.data.getDateTime().toString(),
                  "parish": widget.data.selectedChurch.id,
                  "intention": intention.text.trim(),
                  "attendees": attendees.text.trim(),
                  "user": userId,
                  "donation": donation,
                });
                showSuccess(context,
                    message: 'Mass Booking completed succesfully');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccesful(
                      bookingData: widget.data,
                      bookingId: res.id,
                    ),
                  ),
                );
              } catch (e) {
                final err = e as ClientException;
                showError(context,
                    message: 'Error occured ${err.response['message']}');
              }
            }
          },
          radius: 12,
          backgroundcolor:
              donation == null ? AppColors.greenDisabled : AppColors.green,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.calendar,
                  color: Colors.white,
                  size: 16,
                ),
                Gap(8),
                Text(
                  'Book Mass',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
