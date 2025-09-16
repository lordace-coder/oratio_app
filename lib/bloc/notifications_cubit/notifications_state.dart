part of 'notifications_cubit.dart';

abstract class NotificationState {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<RecordModel> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationUpdated extends NotificationState {
  final RecordModel updatedNotification;

  const NotificationUpdated(this.updatedNotification);

  @override
  List<Object> get props => [updatedNotification];
}

class NotificationError extends NotificationState {
  final String error;

  NotificationError(this.error) {}

  @override
  List<Object> get props => [error];
}
