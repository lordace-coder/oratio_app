// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oratio_app/bloc/booking_bloc/state.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/ui/pages/mass_detail_page.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

class MassBookingPage extends StatefulWidget {
  const MassBookingPage({super.key});

  @override
  State<MassBookingPage> createState() => _MassBookingPageState();
}

class _MassBookingPageState extends State<MassBookingPage> {
  List<DateTime> selectedDates = [];
  TimeOfDay? fromTime;
  TimeOfDay? finishTime;
  final controller = TextEditingController();
  RecordModel? selectedChurch;
  String searchQuery = '';

  void selectChurch(RecordModel selection) {
    setState(() {
      selectedChurch = selectedChurch?.id == selection.id ? null : selection;
    });
  }

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

  Future<void> selectFinishTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: finishTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        finishTime = time;
      });
    }
  }

  void handleBookNow() {
    final bookingData = MassBookingData(
      selectedDates: selectedDates,
      fromTime: fromTime,
      finishTime: finishTime,
      selectedChurch: selectedChurch!,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MassDetailPage(
        data: bookingData,
      ),
    ));
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelectionCard(context),
                const Gap(16),
                _buildTimeSelectionCard(context),
                const Gap(16),
                _buildParishSection(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BookingButton(
            isEnabled: selectedDates.isNotEmpty &&
                fromTime != null &&
                finishTime != null &&
                selectedChurch != null,
            onPressed: handleBookNow,
          ),
        ),
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

  Widget _buildTimeSelectionCard(BuildContext context) {
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
            'Select Time',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectFromTime,
                  icon: const Icon(FontAwesomeIcons.clock),
                  label: Text(fromTime == null
                      ? 'Select From Time'
                      : 'From: ${fromTime!.format(context)}'),
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
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectFinishTime,
                  icon: const Icon(FontAwesomeIcons.clock),
                  label: Text(finishTime == null
                      ? 'Select Finish Time'
                      : 'Finish: ${finishTime!.format(context)}'),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParishSection(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                size: 13,
                color: AppColors.warning,
              ),
              const Gap(7),
              Text(
                "You can only book mass in parishes you attend",
                style: TextStyle(color: AppColors.warning),
              ),
            ],
          ),
          const Gap(10),
          CustomSearchBar(
            controller: controller,
            onSubmit: (String value) {
              updateSearchQuery(value);
            },
          ),
          const Gap(24),
          BlocConsumer<ProfileDataCubit, ProfileDataState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is ProfileDataLoaded) {
                if (state.profile.parish.isNotEmpty) {
                  final filteredParishes = state.profile.parish.where((parish) {
                    return parish
                        .getStringValue('name')
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  return Column(
                    children: [
                      ...filteredParishes.map((i) => buildChurchItem(context, i,
                              () {
                            selectChurch(i);
                          },
                              selectedChurch != null
                                  ? i.id == selectedChurch!.id
                                  : false))
                    ],
                  );
                }
              }
              context.read<ProfileDataCubit>().getMyProfile();
              return const NoParishYet();
            },
          )
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
