import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:dio/dio.dart';
part 'notifications_state.dart';

enum NotificationAction { read, delete }

class NotificationCubit extends Cubit<NotificationState> {
  final PocketBase _pocketBase;
  int _unreadCount = 0;
  late Dio dio;
  NotificationCubit(this._pocketBase) : super(NotificationInitial()) {
    dio = Dio(BaseOptions(
        baseUrl: _pocketBase.baseUrl,
        headers: {"Authorization": "Bearer ${_pocketBase.authStore.token}"},
        contentType: 'application/json'));
  }

  Future<void> fetchNotifications() async {
    try {
      emit(NotificationLoading());
      final records = await _pocketBase
          .collection('notifications')
          .getList(sort: '-created');
      emit(NotificationLoaded(records.items));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      emit(const NotificationLoaded([]));
      handleNotificationAction(NotificationAction.delete);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _pocketBase.collection('notifications').delete(id);
      final newState = (state as NotificationLoaded)
          .notifications
          .where((item) => item.id != id);
      emit(NotificationLoaded(newState.toList()));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  static void deleteNotifications(List args) async {
    final dio = args[0];
    try {
      await dio.delete("/notifications/deleteAll");
    } catch (e) {
      print("error e");
    }
  }

  static void handleReadNotifications(List args) async {
    final dio = args[0];
    try {
      await dio.get("/notifications/markAsRead");
    } catch (e) {
      print("error e");
    }
  }

  void handleNotificationAction(NotificationAction action) async {
    switch (action) {
      case NotificationAction.delete:
        await Isolate.spawn(deleteNotifications, [dio]);
        break;
      case NotificationAction.read:
        await Isolate.spawn(handleReadNotifications, [dio]);
      default:
    }
  }

  void realtimeConnection() async {
    if (!_pocketBase.authStore.isValid) {
      return;
    }
    final userId = _pocketBase.authStore.model.id;

    _pocketBase.collection('notifications').subscribe('*', (e) {
      if (e.action == 'create') {
        if (e.record == null) return;
        // PopupNotification.show(
        //   title: e.record!.getStringValue('title'),
        //   message: e.record!.getStringValue('notification'),
        // );
        _unreadCount = 0;
        unreadNotificationCount();
      }
    }, filter: 'user = "$userId" ');
  }

  ///to get the unread count to increase reset it to zero and call this function again
  int unreadNotificationCount() {
    if (_unreadCount != 0) return _unreadCount;
    if (state is NotificationLoaded) {
      // count unread notifications
      List<RecordModel> d = (state as NotificationLoaded).notifications;
      return (state as NotificationLoaded)
          .notifications
          .where((notification) => !notification.getBoolValue('read'))
          .length;
    }
    return _unreadCount;
  }

  @override
  Future<void> close() {
    _pocketBase.collection('notifications').unsubscribe('*');
    return super.close();
  }

  Future<void> logout() async {
    await _pocketBase.collection('notifications').unsubscribe('*');
  }
}
