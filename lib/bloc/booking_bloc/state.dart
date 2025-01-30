import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class MassBookingData {
  final List<DateTime> selectedDates;
  final TimeOfDay? fromTime;
  final TimeOfDay? finishTime;
  final RecordModel selectedChurch;

  MassBookingData({
    required this.selectedDates,
    this.fromTime,
    this.finishTime,
    required this.selectedChurch,
  });

  DateTime getDateTime() {
    if (selectedDates.isEmpty) {
      throw ArgumentError("At least one date must be selected");
    }
    return selectedDates.first;
  }

  String getMassTimeRange(BuildContext context) {
    if (fromTime == null || finishTime == null) {
      throw ArgumentError("Both fromTime and finishTime must be provided");
    }
    return '${fromTime!.format(context)} - ${finishTime!.format(context)}';
  }

  String getMassDuration() {
    if (fromTime == null || finishTime == null) {
      throw ArgumentError("Both fromTime and finishTime must be provided");
    }
    final start = DateTime(0, 0, 0, fromTime!.hour, fromTime!.minute);
    final end = DateTime(0, 0, 0, finishTime!.hour, finishTime!.minute);
    final duration = end.difference(start);
    return 'Duration: ${duration.inHours}h ${duration.inMinutes % 60}m';
  }
}

String printDayDetails(DateTime date) {
  const daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  return daysOfWeek[date.weekday - 1];
}
