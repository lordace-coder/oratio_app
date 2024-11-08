import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

enum SelectedDateType { today, tomorrow, custom }

enum SelectedTimeType { morning, lateMorning, noon, afternoon }

class MassBookingPage extends StatefulWidget {
  const MassBookingPage({super.key});

  @override
  State<MassBookingPage> createState() => _MassBookingPageState();
}

class _MassBookingPageState extends State<MassBookingPage> {
  SelectedDateType? massDate;
  SelectedTimeType? massTime;
  final controller = TextEditingController();

  bool selectedDateById(int id) =>
      massDate != null && SelectedDateType.values[id - 1] == massDate;

  bool selectedTimeById(int id) =>
      massTime != null && SelectedTimeType.values[id - 1] == massTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: createAppBar(
        context,
        label: 'Book Mass',
        actions: [
          PopupMenuButton(
            icon: const Icon(FontAwesomeIcons.ellipsisVertical),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              _buildPopupMenuItem(
                icon: FontAwesomeIcons.solidBookmark,
                label: 'My Churches',
                onTap: () {},
              ),
              _buildPopupMenuItem(
                icon: FontAwesomeIcons.church,
                label: 'All Churches',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Gap(12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _DateOption(
                            isSelected: selectedDateById(1),
                            label: 'Today',
                            date: 'Oct 1',
                            onTap: () => setState(
                                () => massDate = SelectedDateType.today),
                          ),
                          _DateOption(
                            isSelected: selectedDateById(2),
                            label: 'Tomorrow',
                            date: 'Oct 2',
                            onTap: () => setState(
                                () => massDate = SelectedDateType.tomorrow),
                          ),
                          _DateOption(
                            isSelected: selectedDateById(3),
                            label: 'Custom',
                            date: '...',
                            onTap: () => setState(
                                () => massDate = SelectedDateType.custom),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Gap(12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _TimeSlot(
                          isSelected: selectedTimeById(1),
                          time: '8:00 AM',
                          label: 'Morning Mass',
                          onTap: () => setState(
                              () => massTime = SelectedTimeType.morning),
                        ),
                        _TimeSlot(
                          isSelected: selectedTimeById(2),
                          time: '10:00 AM',
                          label: 'Late Morning Mass',
                          onTap: () => setState(
                              () => massTime = SelectedTimeType.lateMorning),
                        ),
                        _TimeSlot(
                          isSelected: selectedTimeById(3),
                          time: '12:00 PM',
                          label: 'Noon Mass',
                          onTap: () =>
                              setState(() => massTime = SelectedTimeType.noon),
                        ),
                        _TimeSlot(
                          isSelected: selectedTimeById(4),
                          time: '2:00 PM',
                          label: 'Afternoon Mass',
                          onTap: () => setState(
                              () => massTime = SelectedTimeType.afternoon),
                        ),
                      ],
                    ),
                    const Gap(24),
                    _buildParishSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BookingButton(
            isEnabled: massDate != null && massTime != null,
            onPressed: () => context.pushNamed(RouteNames.massDetail),
          ),
        ),
      ),
    );
  }

  Widget _buildParishSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select A Parish Or Mass Center',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.pushNamed(RouteNames.parishpage),
              child: Text(
                'See More',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        CustomSearchBar(controller: controller),
        const Gap(24),
        const NoParishYet(),
      ],
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

class _DateOption extends StatelessWidget {
  final bool isSelected;
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateOption({
    required this.isSelected,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              date,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final bool isSelected;
  final String time;
  final String label;
  final VoidCallback onTap;

  const _TimeSlot({
    required this.isSelected,
    required this.time,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[900],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey[600],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
