import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  final PocketBase pb;
  final SharedPreferences pref;
  BackendService(this.pref)
      : pb = PocketBase('http://10.0.2.2:8090',
            authStore: AsyncAuthStore(
              save: (String data) async => pref.setString('pb_auth', data),
              initial: pref.getString('pb_auth'),
            ));
}

class PocketBaseServiceCubit extends Cubit<BackendService> {
  PocketBaseServiceCubit(SharedPreferences pref) : super(BackendService(pref));
}
