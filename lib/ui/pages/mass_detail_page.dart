import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class MassDetailPage extends StatefulWidget {
  const MassDetailPage({super.key});

  @override
  State<MassDetailPage> createState() => _MassDetailPageState();
}

class _MassDetailPageState extends State<MassDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => MassBookBottomSheet(
          scrollController: scrollController,
          slideAnimation: _slideAnimation,
          fadeAnimation: _fadeAnimation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 143, 19, 19),
            const Color.fromARGB(255, 143, 19, 19).withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showBookingSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          label: const Row(
            children: [
              Icon(FontAwesomeIcons.calendar, size: 16),
              Gap(8),
              Text(
                'Book Mass',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  _buildMassHeader(),
                  const Gap(20),
                  _buildMassInfo(),
                  const Gap(100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMassHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sunday Mass',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.church,
                color: Colors.white70,
                size: 16,
              ),
              const Gap(8),
              Text(
                'St. Mary\'s Cathedral',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMassInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            FontAwesomeIcons.clock,
            '9:00 AM - 10:30 AM',
            'Duration: 1h 30m',
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow(
            FontAwesomeIcons.calendarDay,
            'Every Sunday',
            'Regular Mass Schedule',
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow(
            FontAwesomeIcons.users,
            '200 Capacity',
            '120 Registered Today',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(FontAwesomeIcons.chevronLeft, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton(
            icon: const Icon(
              FontAwesomeIcons.ellipsisVertical,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              _buildPopupMenuItem(
                FontAwesomeIcons.solidBookmark,
                'My Churches',
                () {},
              ),
              _buildPopupMenuItem(
                FontAwesomeIcons.church,
                'All Churches',
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[800]),
          const Gap(12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class MassBookBottomSheet extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final ScrollController scrollController;

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
          _buildSuccessMessage(),
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
          radius: 12,
          backgroundcolor: AppColors.greenDisabled,
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
