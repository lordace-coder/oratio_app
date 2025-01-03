import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/ads_bloc/ads_state.dart';
import 'package:oratio_app/ui/pages/pages.dart';
import 'package:pocketbase/pocketbase.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdsRepo _repository;

  AdsCubit(this._repository) : super(const AdsState());

  Future<void> loadAds() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final ads = await _repository.getAds();
      emit(state.copyWith(ads: ads, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> incrementViews(String adId) async {
    try {
      await _repository.incrementViews(adId);
      final updatedAds = state.ads.map((ad) {
        if (ad.id == adId) {
          return Ad(
            id: ad.id,
            location: ad.location,
            clicks: ad.clicks,
            views: (ad.views ?? 0) + 1,
            image: ad.image,
            title: ad.title,
            description: ad.description,
            callToAction: ad.callToAction,
            created: ad.created,
            updated: ad.updated,
          );
        }
        return ad;
      }).toList();
      emit(state.copyWith(ads: updatedAds));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> incrementClicks(String adId) async {
    try {
      await _repository.incrementClicks(adId);
      final updatedAds = state.ads.map((ad) {
        if (ad.id == adId) {
          return Ad(
            id: ad.id,
            location: ad.location,
            clicks: (ad.clicks ?? 0) + 1,
            views: ad.views,
            image: ad.image,
            title: ad.title,
            description: ad.description,
            callToAction: ad.callToAction,
            created: ad.created,
            updated: ad.updated,
          );
        }
        return ad;
      }).toList();
      emit(state.copyWith(ads: updatedAds));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

// Repository Interface
// abstract class AdsRepository {
//   Future<List<Ad>> getAds();
//   Future<void> incrementViews(String adId);
//   Future<void> incrementClicks(String adId);
// }

class AdsRepo {
  final PocketBase pb;

  AdsRepo(this.pb);

  Future<List<Ad>> getAds() async {
    if (!pb.authStore.isValid) {
      await pb.collection('users').authWithPassword('email', 'password');
    }
    final records = await pb.collection('ads').getList(
          page: 1,
          // perPage: 50,
          perPage: 3,
        );

    return records.items.map((record) {
      if (record.data['image'] != null &&
          (record.data['image'] as String).isNotEmpty) {
        final image =
            pb.getFileUrl(record, record.getStringValue('image')).toString();

        return Ad(
          id: record.id,
          location: record.data['location'],
          clicks: record.data['clicks'],
          views: record.data['views'],
          image: image,
          title: record.data['title'],
          description: record.data['description'],
          callToAction: record.data['call_to_action'],
          created: DateTime.parse(record.created),
          updated: DateTime.parse(record.updated),
        );
      }
      return Ad(
        id: record.id,
        location: record.data['location'],
        clicks: record.data['clicks'],
        views: record.data['views'],
        image: record.data['image'],
        title: record.data['title'],
        description: record.data['description'],
        callToAction: record.data['call_to_action'],
        created: DateTime.parse(record.created),
        updated: DateTime.parse(record.updated),
      );
    }).toList();
  }

  Future<void> incrementViews(String adId) async {
    final record = await pb.collection('ads').getOne(adId);
    final currentViews = record.data['views'] ?? 0;

    await pb.collection('ads').update(adId, body: {
      'views': currentViews + 1,
    });
  }

  Future<void> deleteAd(String adId) async {
    await pb.collection('ads').delete(adId);
  }

  Future<void> incrementClicks(String adId) async {
    final record = await pb.collection('ads').getOne(adId);
    final currentClicks = record.data['clicks'] ?? 0;

    await pb.collection('ads').update(adId, body: {
      'clicks': currentClicks + 1,
    });
  }
}
