part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class InitializeEvent extends AuthEvent {}
final class AuthLoadingEvent extends AuthEvent{}

final class AuthSubmitEvent extends AuthEvent {
  final String access;
  final String refresh;
  AuthSubmitEvent({required this.access, required this.refresh});
}

final class CreateUserEvent extends AuthEvent {
  final Map<String, String> data;
  CreateUserEvent(this.data);
}

final class VerifyUserEvent extends AuthEvent {}

final class LogoutEvent extends AuthEvent {}
