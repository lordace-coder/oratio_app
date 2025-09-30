// ignore_for_file: public_member_api_docs, sort_constructors_first
// prayer_request.dart

import 'package:flutter/foundation.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:pocketbase/pocketbase.dart';

class PrayerRequest {
  final String id;
  final String request;
  final RecordModel user;
  final List<String> comment;
  final List<String> praying;
  final bool urgent;
  final String created;
  PrayerRequest({
    required this.id,
    required this.request,
    required this.user,
    required this.comment,
    required this.praying,
    required this.urgent,
    required this.created,
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] ?? '',
      request: json['request'] ?? '',
      created: json['request'] ?? '',
      user: json['user'] ?? {},
      comment: List<String>.from(json['comment'] ?? []),
      praying: List<String>.from(json['praying'] ?? []),
      urgent: json['urgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request,
      'created': created,
      'user': user,
      'comment': comment,
      'praying': praying,
      'urgent': urgent,
    };
  }

  PrayerRequest copyWith({
    String? id,
    String? request,
    RecordModel? user,
    List<String>? comment,
    List<String>? praying,
    bool? urgent,
    String? created,
  }) {
    return PrayerRequest(
      id: id ?? this.id,
      request: request ?? this.request,
      user: user ?? this.user,
      comment: comment ?? this.comment,
      praying: praying ?? this.praying,
      urgent: urgent ?? this.urgent,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'request': request,
      'user': user.data,
      'comment': comment,
      'praying': praying,
      'urgent': urgent,
      'created': created,
    };
  }

  @override
  String toString() {
    return 'PrayerRequest(id: $id, request: $request, user: $user, comment: $comment, praying: $praying, urgent: $urgent, created: $created)';
  }

  @override
  bool operator ==(covariant PrayerRequest other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.request == request &&
        other.user == user &&
        listEquals(other.comment, comment) &&
        listEquals(other.praying, praying) &&
        other.urgent == urgent &&
        other.created == created;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        request.hashCode ^
        user.hashCode ^
        comment.hashCode ^
        praying.hashCode ^
        urgent.hashCode ^
        created.hashCode;
  }
}

// prayer_request_state.dart
abstract class PrayerRequestState {
  const PrayerRequestState();
}

class PrayerRequestInitial extends PrayerRequestState {}

class PrayerRequestLoading extends PrayerRequestState {}

class PrayerRequestLoaded extends PrayerRequestState {
  final List<PrayerRequest> prayerRequests;

  PrayerRequestLoaded(this.prayerRequests);
}

class PrayerRequestError extends PrayerRequestState {
  final String message;

  PrayerRequestError(this.message);
}
