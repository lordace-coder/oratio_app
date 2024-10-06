import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:oratio_app/networkProvider/authentication.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserModel?> {
  UserCubit() : super(null);

  void logout() {
    emit(null);
  }

  Future getUserData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString('access')!;
    final data = await getUser(token);
    // if successfull
    if (data.containsKey('error')) {
      // todo handle errors
    } else {
      final UserModel user = UserModel.fromMap(data);
     
      emit(user);
    }
  }

  void initialize() async {
    if (state == null) {
      await getUserData();
    }
  }
}
