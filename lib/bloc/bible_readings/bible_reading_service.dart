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
  Future<List<Map<String, dynamic>>> getReadings() async {
    final box = await _openBox();
    final readings =
        box.get(readingsKey, defaultValue: <Map<String, dynamic>>[]);
    return List<Map<String, dynamic>>.from(readings);
  }

  // Check if readings need to be updated (older than 7 days)
  Future<bool> needsUpdate() async {
    final box = await _openBox();
    return (await getReadings()).isEmpty;
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
