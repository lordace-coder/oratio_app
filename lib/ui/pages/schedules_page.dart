import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

class SchedulesPage extends StatelessWidget {
  const SchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, label: 'My Schedule'),
      body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => ScheduleItem(
                title: "Design Team Meeting",
                dateTime: DateTime(
                    2024, 10, 25, 10, 30), // Year, Month, Day, Hour, Minute
                location: "Conference Room 2B",
                category: "Meeting",
                categoryColor: Colors.blue,
                isCompleted: false,
              )),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final String location;
  final Color categoryColor;
  final String category;
  final bool isCompleted;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.categoryColor,
    required this.category,
    this.isCompleted = false,
  });

  String _getFormattedTime() {
    return DateFormat('h:mm a').format(dateTime);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final scheduleDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (scheduleDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (scheduleDate == tomorrow) {
      return 'Tomorrow';
    } else if (scheduleDate == yesterday) {
      return 'Yesterday';
    } else if (scheduleDate.year == now.year) {
      return DateFormat('MMM d').format(dateTime); // e.g., "Oct 25"
    } else {
      return DateFormat('MMM d, y').format(dateTime); // e.g., "Oct 25, 2024"
    }
  }

  String _getDayName() {
    return DateFormat('EEE').format(dateTime); // e.g., "Mon"
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Main Card
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Date & Time Column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Date Display
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getDayName(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateTime.day.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Time Display
                        Text(
                          _getFormattedTime().split(' ')[0], // Hours
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _getFormattedTime().split(' ')[1], // AM/PM
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Vertical Divider
                    Container(
                      height: 85,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey.withOpacity(0.2),
                    ),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getFormattedDate(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isCompleted
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
