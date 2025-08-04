import 'package:hive/hive.dart';

class BibleReadingService {
  static const String boxName = 'bible_readings';
  static const String readingsKey = 'readings';
  static const String timestampKey = 'timestamp';

  // Initialize Hive box
  Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  // Save readings with timestamp
  Future<void> saveReadings(List<Map<String, dynamic>> readings) async {
    final box = await _openBox();
    final currentTime = DateTime.now();

    await box.put(readingsKey, readings);
    await box.put(timestampKey, currentTime.toIso8601String());
  }

  // Get stored readings
  Future<List<Map<dynamic, dynamic>>> getReadings() async {
    final box = await _openBox();
    final readings =
        box.get(readingsKey, defaultValue: <Map<dynamic, dynamic>>[]);
    return List<Map<dynamic, dynamic>>.from(readings);
  }

// Add this method to your BibleReadingService class
  Future<String> getLastUpdateTimeAgo() async {
    final box = await _openBox();
    final timestamp = box.get(timestampKey);

    if (timestamp == null) {
      return 'Never updated';
    }

    final lastUpdate = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if readings need to be updated (older than 1 day)
  Future<bool> needsUpdate() async {
    final box = await _openBox();
    final readings = await getReadings();
    if (readings.isEmpty) return true;
    final timestamp = box.get(timestampKey);
    if (timestamp == null) return true;
    final lastUpdate = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inDays >= 1;
  }

  // Update readings if needed
  Future<void> updateIfNeeded(
      Future<List<Map<String, dynamic>>> Function() fetchNewReadings) async {
    if (await needsUpdate()) {
      final newReadings = await fetchNewReadings();
      await saveReadings(newReadings);
    }
  }

  // Clear stored readings
  Future<void> clearReadings() async {
    final box = await _openBox();
    await box.clear();
  }
}
