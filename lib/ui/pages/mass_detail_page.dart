import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/booking_bloc/state.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/sheets.dart';

class MassDetailPage extends StatefulWidget {
  const MassDetailPage({super.key, required this.data});
  final MassBookingData data;
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
          data: widget.data,
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
                  _buildMassInfo(context),
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
            widget.data.selectedDates.length > 1
                ? 'Multiple Mass Bookings'
                : '${printDayDetails(widget.data.getDateTime())} Mass',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.data.selectedDates.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${widget.data.selectedDates.length} dates selected',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
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
                widget.data.selectedChurch.getStringValue('name'),
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

  Widget _buildMassInfo(BuildContext context) {
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
            widget.data.getMassTimeRange(context),
            widget.data.getMassDuration(),
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
