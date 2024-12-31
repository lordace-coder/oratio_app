import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:pocketbase/pocketbase.dart';

class CentralCubit extends Cubit<void> {
  final ProfileDataCubit profileDataCubit;
  final PrayerRequestCubit prayerRequestCubit;
  final PostCubit postCubit;
  final NotificationCubit notificationCubit;
  final MessageCubit messageCubit;
  final ChatCubit chatCubit;
  final PocketBase pb;

  CentralCubit({
    required this.profileDataCubit,
    required this.prayerRequestCubit,
    required this.postCubit,
    required this.notificationCubit,
    required this.messageCubit,
    required this.chatCubit,
    required this.pb,
  }) : super(null);

  Future<void> initialize(BuildContext context) async {
    await profileDataCubit.getMyProfile();
    await prayerRequestCubit.fetchPrayerRequests();
    await postCubit.fetchPosts();
    await notificationCubit.fetchNotifications();
    await messageCubit.loadMessages(pb.authStore.model.id);
    chatCubit.subscribeToMessages(context);
    notificationCubit.realtimeConnection();
  }

  Future<void> logout() async {
    profileDataCubit.emit(ProfileDataInitial());
    prayerRequestCubit.emit(PrayerRequestInitial());
    postCubit.emit(PostInitial());
    notificationCubit.emit(NotificationInitial());
    await notificationCubit.logout();
    messageCubit.logout();
    chatCubit.logout();
    pb.authStore.clear();
  }
}
