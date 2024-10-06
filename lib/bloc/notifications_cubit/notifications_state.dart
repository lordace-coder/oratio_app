part of 'notifications_cubit.dart';

class Notification {
  String? title = 'New Notification';
  String notification;
  bool read;
  String formated_time;
  Notification({
    required this.title,
    required this.notification,
    required this.read,
    required this.formated_time,
  });

  Notification copyWith({
    String? title,
    String? notification,
    bool? read,
    String? formated_time,
  }) {
    return Notification(
      title: title ?? this.title,
      notification: notification ?? this.notification,
      read: read ?? this.read,
      formated_time: formated_time ?? this.formated_time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'notification': notification,
      'read': read,
      'formated_time': formated_time,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      title: map['title'] != null ? map['title'] as String : 'New Notification',
      notification: map['notification'] as String,
      read: map['read'] as bool,
      formated_time: map['formated_time'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Notification(title: $title, notification: $notification, read: $read, formated_time: $formated_time)';
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.notification == notification &&
        other.read == read &&
        other.formated_time == formated_time;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        notification.hashCode ^
        read.hashCode ^
        formated_time.hashCode;
  }
}
