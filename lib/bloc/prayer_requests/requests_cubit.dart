// prayer_request_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:pocketbase/pocketbase.dart';

class PrayerRequestCubit extends Cubit<PrayerRequestState> {
  final PocketBase pb;

  PrayerRequestCubit(this.pb) : super(PrayerRequestInitial());

  Future<void> fetchPrayerRequests() async {
    try {
      emit(PrayerRequestLoading());

      final records = await pb.collection('prayer_requests').getFullList(
            sort: '-created',
          );

      final prayerRequests = records.map((record) {
        return PrayerRequest.fromJson(record.toJson());
      }).toList();

      emit(PrayerRequestLoaded(prayerRequests));
    } catch (e) {
      emit(PrayerRequestError(e.toString()));
    }
  }

  Future<void> createPrayerRequest({
    required String request,
    required bool urgent,
  }) async {
    try {
      emit(PrayerRequestLoading());

      final body = {
        "request": request,
        "urgent": urgent,
      };

      await pb.collection('prayer_requests').create(body: body);

      await fetchPrayerRequests();
    } catch (e) {
      emit(PrayerRequestError(e.toString()));
    }
  }

  Future<void> togglePraying(
      String requestId, List<String> currentPraying) async {
    try {
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

      await fetchPrayerRequests();
    } catch (e) {
      emit(PrayerRequestError(e.toString()));
    }
  }

  Future<void> deletePrayerRequest(String id) async {
    try {
      emit(PrayerRequestLoading());

      await pb.collection('prayer_requests').delete(id);

      await fetchPrayerRequests();
    } catch (e) {
      emit(PrayerRequestError(e.toString()));
    }
  }
}
