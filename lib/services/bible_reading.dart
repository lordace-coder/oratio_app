import 'package:oratio_app/networkProvider/requests.dart';

Future<List<Map<String, dynamic>>> fetchReadings() async {
  final data = <Map<String, dynamic>>[];

  try {
    for (var i = 0; i < 7; i++) {
      final res = await getRandomBibleReading();
      data.add(res as Map<String, dynamic>);
    }
  // ignore: empty_catches
  } catch (e) {
  }

  return data;
}
