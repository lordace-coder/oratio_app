// prayer_request_cubit.dart
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:pocketbase/pocketbase.dart';

class PrayerRequestHelper {
  final PocketBase pb;

  PrayerRequestHelper(this.pb);

  Future<List<PrayerRequest>> fetchPrayerRequests() async {
    final records = await pb
        .collection('prayer_requests')
        .getFullList(sort: '-created', expand: 'user');
    final prayerRequests = records.map((record) {
      return PrayerRequest(
          comment: record.getListValue('comment'),
          id: record.id,
          praying: record.getListValue('praying'),
          request: record.getStringValue('request'),
          urgent: record.getBoolValue('urgent'),
          user: record.expand['user']!.first,
          created: record.created);
    }).toList();
    return prayerRequests;
  }

  Future<void> createPrayerRequest({
    required String request,
    required bool urgent,
  }) async {
    final body = {
      "request": request,
      "urgent": urgent,
      "user": pb.authStore.model.id.toString(),
    };
    await pb.collection('prayer_requests').create(body: body);
  }

  Future<void> togglePraying(
      String requestId, List<String> currentPraying) async {
    final userId = pb.authStore.model.id;
    List<String> updatedPraying = List.from(currentPraying);

    if (currentPraying.contains(userId)) {
      updatedPraying.remove(userId);
    } else {
      updatedPraying.add(userId);
    }

    await pb.collection('prayer_requests').update(
      requestId,
      body: {'praying': updatedPraying},
    );
  }

  Future<void> deletePrayerRequest(String id) async {
    await pb.collection('prayer_requests').delete(id);
  }
}
