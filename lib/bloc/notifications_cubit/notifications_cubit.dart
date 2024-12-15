import 'package:bloc/bloc.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:pocketbase/pocketbase.dart';
part 'notifications_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final PocketBase _pocketBase;

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
    try {
      print('subscribed');

      _pocketBase.collection('notifications').subscribe('*', (e) {
        if (e.action == 'create') {
          print(e.record);
          if (e.record == null) return;
          PopupNotification.show(
            title: e.record!.getStringValue('title'),
            message: e.record!.getStringValue('notification'),
          );
        }
      }, filter: 'user = $userId');
      print('subscribed');
    } catch (e) {
      print('realtime error $e');
      emit(NotificationError(e.toString()));
    }
  }
}
