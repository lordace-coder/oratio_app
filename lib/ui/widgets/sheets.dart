import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';
import 'package:pocketbase/pocketbase.dart';

class MassBookBottomSheet extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final ScrollController scrollController;
  RecordModel? donation;

  MassBookBottomSheet({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scrollController,
  });

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
        controller: scrollController,
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
    return Column(
      children: [
        SubmitButtonV1(
          ontap: () {
            context.pushNamed(
              RouteNames.paymentSuccesful,
              pathParameters: {'status': ''},
            );
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
        ),
        const Gap(12),
        SubmitButtonV1(
          ontap: () {
            if (donation != null) {
              // handle booking
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
