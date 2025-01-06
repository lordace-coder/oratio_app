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
  SelectedDateType? massDate;
  SelectedTimeType? massTime;
  final controller = TextEditingController();
  DateTime? selectedDate;
  RecordModel? selectedChurch;
  bool selectedDateById(int id) =>
      massDate != null && SelectedDateType.values[id - 1] == massDate;

  bool selectedTimeById(int id) =>
      massTime != null && SelectedTimeType.values[id - 1] == massTime;
  String formattedDate = '';

  void selectChurch(RecordModel selection) {
    if (selectedChurch != null) {
      if (selectedChurch!.id == selection.id) {
        setState(() {
          selectedChurch = null;
        });
        return;
      }
    }
    setState(() {
      selectedChurch = selection;
    });
  }

  void handleBookNow() {
    final bookingData = MassBookingData(
        massDate: massDate!,
        selectedDate: selectedDate,
        massTime: massTime!,
        selectedChurch: selectedChurch!);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MassDetailPage(
              data: bookingData,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM d');
    if (selectedDate != null) {
      formattedDate = format.format(selectedDate!);
    }
    DateTime now = DateTime.now();
    DateTime tmmrw = DateTime(
      now.year,
      now.month,
      now.day + 1,
      now.hour,
      now.minute,
      now.second,
    );
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
                            date: format.format(now),
                            onTap: () => setState(
                                () => massDate = SelectedDateType.today),
                          ),
                          _DateOption(
                            isSelected: selectedDateById(2),
                            label: 'Tomorrow',
                            date: format.format(tmmrw),
                            onTap: () => setState(
                                () => massDate = SelectedDateType.tomorrow),
                          ),
                          _DateOption(
                            isSelected: selectedDateById(3),
                            label: 'Custom',
                            date: selectedDate == null
                                ? '...'
                                : " $formattedDate",
                            onTap: () async {
                              DateTime nextMonth = DateTime(
                                now.year,
                                now.month + 1,
                                now.day,
                                now.hour,
                                now.minute,
                                now.second,
                              );

                              final day = await showDatePicker(
                                  initialDate: selectedDate,
                                  context: context,
                                  firstDate: now,
                                  lastDate: nextMonth);
                              if (day != null) {
                                setState(
                                    () => massDate = SelectedDateType.custom);
                                selectedDate = day;
                              }
                            },
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
            isEnabled:
                massDate != null && massTime != null && selectedChurch != null,
            onPressed: handleBookNow,
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
        BlocConsumer<ProfileDataCubit, ProfileDataState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileDataLoaded) {
              if (state.profile.parish.isNotEmpty) {
                return Column(
                  children: [
                    ...state.profile.parish.map((i) =>
                        buildChurchItem(context, i, () {
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
                    .toString(), // Use actual image URL
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
