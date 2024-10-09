part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

///user is not authenticated
final class Anonymous extends AuthState {}

///user is not authenticated
final class AuthLoading extends AuthState {
  AuthLoading() {
    Future.delayed(const Duration(seconds: 3));
    print('state is Authloading for 3 seconds');
  }
}

///user has been authenticated succesfully
final class Authenticated extends AuthState {
  final String access;
  final String refresh;
  SharedPreferences pref;

  Authenticated(
      {required this.access, required this.refresh, required this.pref}) {
    pref.setString('access', access);
    pref.setString('refresh', refresh);
  }
}
