import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/ads_bloc/ads_cubit.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:pocketbase/pocketbase.dart';

class CentralCubit extends Cubit<List> {
  final ProfileDataCubit profileDataCubit;
  final PostHelper postHelper;
  final NotificationCubit notificationCubit;
  final MessageCubit messageCubit;
  final ChatCubit chatCubit;
  final PocketBase pb;
  final AdsRepo adsRepo;
  List<RecordModel> liveParishes = [];

  CentralCubit({
    required this.adsRepo,
    required this.profileDataCubit,
    required this.postHelper,
    required this.notificationCubit,
    required this.messageCubit,
    required this.chatCubit,
    required this.pb,
  }) : super([]);

  Future<void> initialize(BuildContext context) async {
    try {
      // pb.authStore.clear();

      if (pb.authStore.isValid) {
        await profileDataCubit.getMyProfile();
        await notificationCubit.fetchNotifications();
        await messageCubit.loadMessages(pb.authStore.model.id);
        await adsRepo.getAds();
        chatCubit.subscribeToMessages(context);
        notificationCubit.realtimeConnection();
        getFeeds();
      }
    } catch (e) {
      debugPrint('initialization error $e');
    }
    // NotificationService.initialize(context);
  }

  Future<void> logout() async {
    profileDataCubit.emit(ProfileDataInitial());
    notificationCubit.emit(NotificationInitial());
    await notificationCubit.logout();
    messageCubit.logout();
    chatCubit.logout();
    pb.authStore.clear();
  }

  Future<void> getFeeds() async {
    final posts = await postHelper.fetchPosts();
    // final prayerRequests = await prayerRequestHelper.fetchPrayerRequests();
    final ads = await adsRepo.getAds();
    notificationCubit.fetchNotifications();
    await checkLiveParishes();
    emit([...posts, ...ads]..shuffle());
  }

  void deleteAd(String id) {
    adsRepo.deleteAd(id);
    final newFeeds = state.where((feed) => feed.id != id).toList();
    emit(newFeeds);
  }

  Future<List> getMoreFeeds() async {
    final posts = await postHelper.fetchPosts(loadMore: true);
    final ads = await adsRepo.getAds();
    final newFeeds = [...posts, ...ads]..shuffle();
    emit([...state, ...newFeeds]);
    return newFeeds;
  }

  Future<void> checkLiveParishes() async {
    final data = await getParishGoingLive(pb);
    if (data == null) {
      emit([...state]);
      liveParishes = [];
      return;
    }
    liveParishes = [data];
    emit([...state]);
  }

  ///Initialize realtime connections througth the entire app
  Future<void> realTimeInit(BuildContext context) async {
    chatCubit.subscribeToMessages(context);
    notificationCubit.realtimeConnection();
  }
}
