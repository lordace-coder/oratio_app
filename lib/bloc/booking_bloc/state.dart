import 'package:pocketbase/pocketbase.dart';

enum SelectedDateType { today, tomorrow, custom }

enum SelectedTimeType { morning, lateMorning, noon, afternoon }

class MassBookingData {
  final SelectedDateType massDate;
  final SelectedTimeType massTime;
  DateTime? selectedDate;
  final RecordModel selectedChurch;
  MassBookingData({
    required this.massDate,
    required this.massTime,
    this.selectedDate,
    required this.selectedChurch,
  });

  DateTime getDateTime() {
    DateTime now = DateTime.now();

    // Determine the base date
    DateTime baseDate;
    switch (massDate) {
      case SelectedDateType.today:
        baseDate = DateTime(now.year, now.month, now.day);
        break;
      case SelectedDateType.tomorrow:
        baseDate =
            DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        break;
      case SelectedDateType.custom:
        if (selectedDate == null) {
          throw ArgumentError(
              "selectedDate must be provided for custom date type");
        }
        baseDate = DateTime(
            selectedDate!.year, selectedDate!.month, selectedDate!.day);
        break;
    }

    // Determine the time offset
    int hour;
    switch (massTime) {
      case SelectedTimeType.morning:
        hour = 8; // Example: Morning = 8 AM
        break;
      case SelectedTimeType.lateMorning:
        hour = 10; // Example: Late Morning = 10 AM
        break;
      case SelectedTimeType.noon:
        hour = 12; // Example: Noon = 12 PM
        break;
      case SelectedTimeType.afternoon:
        hour = 15; // Example: Afternoon = 3 PM
        break;
    }

    // Combine the date and time
    return baseDate.add(Duration(hours: hour));
  }

  String getMassTimeRange() {
    // Example times based on massTime; adjust as necessary
    switch (massTime) {
      case SelectedTimeType.morning:
        return '8:00 AM - 9:30 AM';
      case SelectedTimeType.lateMorning:
        return '10:00 AM - 11:30 AM';
      case SelectedTimeType.noon:
        return '12:00 PM - 1:30 PM';
      case SelectedTimeType.afternoon:
        return '3:00 PM - 4:30 PM';
    }
  }

  String getMassDuration() {
    // Example duration for all Mass types; adjust as necessary
    return 'Duration: 1h 30m';
  }
}

String printDayDetails(DateTime date) {
  // Day of the week (numeric: 1 = Monday, 7 = Sunday)
  int weekday = date.weekday;

  // Map numeric weekday to a name
  const daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  String weekdayName =
      daysOfWeek[weekday - 1]; // Adjusting for zero-based index

  // Day of the month
  int dayOfMonth = date.day;
  return weekdayName;
}
