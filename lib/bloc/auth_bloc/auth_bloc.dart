import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:oratio_app/networkProvider/authentication.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(SharedPreferences pref) : super(Anonymous()) {
    // initialize();

    on<AuthLoadingEvent>(
      (event, emit) {
        emit(AuthLoading());
      },
    );

    on<AuthSubmitEvent>((event, emit) async {
      // log user in

      emit(
        Authenticated(
          access: event.access,
          refresh: event.refresh,
          pref: pref,
        ),
      );
    });

    on<LogoutEvent>((event, emit) {
      pref.clear();
      emit(Anonymous());
    });

    ///called when app loads,or as a checker before an important event
    on<InitializeEvent>((event, emit) async {
      //exit this function if user doesnt have access and refresh tokens
      if (pref.getString('access') == null ||
          pref.getString('refresh') == null) {
        emit(Anonymous());
        return;
      }
      var token = pref.getString('access')!;
      var refresh = pref.getString('refresh')!;

      if (pref.getString('access')!.isNotEmpty &&
          pref.getString('refresh')!.isNotEmpty) {
        // todo check if tokens are valid before saving them
        try {
          final isAuth = await isTokenValid(token);
          print(isAuth.toString() + ' is auth');
          if (isAuth == ResponseType.success) {
            emit(Authenticated(
                access: pref.getString('access')!,
                refresh: pref.getString('refresh')!,
                pref: pref));
            return;
          }
          if (isAuth == ResponseType.error) {
            // attempt to refresh token if user is not AUTH
            return refreshTokens(refresh).then((access) {
              emit(
                Authenticated(
                  access: access,
                  refresh: pref.getString('access')!,
                  pref: pref,
                ),
              );
            }).catchError((err) {
              emit(Anonymous());
            });
          }
        } catch (e) {}
        emit(Authenticated(
            access: pref.getString('access')!,
            refresh: pref.getString('refresh')!,
            pref: pref));
      }
    });
  }
  bool isAuthenticated() {
    return state is Authenticated;
  }

  String? getAccessToken() {
    if (!isAuthenticated()) return null;
    return (state as Authenticated).access;
  }

  Future<void> validateUser() async {
    var x = await isTokenValid(getAccessToken()!);
    print('validate user says $x');
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
  }
}
