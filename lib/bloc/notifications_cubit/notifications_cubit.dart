import 'package:bloc/bloc.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:pocketbase/pocketbase.dart';
part 'notifications_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final PocketBase _pocketBase;
  int _unreadCount = 0;
  NotificationCubit(this._pocketBase) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    try {
      emit(NotificationLoading());
      final records = await _pocketBase.collection('notifications').getList();
      emit(NotificationLoaded(records.items));
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

  Future<void> markAsRead(String id) async {
    try {
      await _pocketBase
          .collection('notifications')
          .update(id, body: {'read': true});
      final updatedNotification =
          await _pocketBase.collection('notifications').getOne(id);
      emit(NotificationUpdated(updatedNotification));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void realtimeConnection() async {
    final userId = _pocketBase.authStore.model.id;

    _pocketBase.collection('notifications').subscribe('*', (e) {
      if (e.action == 'create') {
        if (e.record == null) return;
        PopupNotification.show(
          title: e.record!.getStringValue('title'),
          message: e.record!.getStringValue('notification'),
        );
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
    }
    return _unreadCount;
  }

  @override
  Future<void> close() {
    // TODO: implement close
    _pocketBase.collection('notifications').unsubscribe('*');
    return super.close();
  }
}
