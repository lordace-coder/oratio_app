import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:oratio_app/networkProvider/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<List<Notification>> {
  SharedPreferences pref;
  NotificationsCubit(this.pref) : super(<Notification>[]);

  ///gets notifications and updates the state as well as the ui
  Future fetchNotifications() async {
    pref = await SharedPreferences.getInstance();
    List<Notification> notifications = [];

    final data = await getNotifications(pref.getString('access')!);
    // //* check if notifications is empty
    if (data.isEmpty) return;

    for (var item in data) {
      final n = Notification.fromMap(item as Map<String, dynamic>);
      notifications.add(n);
    }
    emit([...notifications]);
  }

  void readAll() async {
    await readAllNotifications(pref.getString('access')!);
    await fetchNotifications();
  }

  void deleteAll() async {
    emit([]);
    await deleteAllNotifications(pref.getString('access')!);
    // await fetchNotifications();
  }
}
