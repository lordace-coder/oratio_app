// prayer_request.dart
class PrayerRequest {
  final String id;
  final String request;
  final Map<String, dynamic> user;
  final List<String> comment;
  final List<String> praying;
  final bool urgent;

  PrayerRequest({
    required this.id,
    required this.request,
    required this.user,
    required this.comment,
    required this.praying,
    required this.urgent,
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] ?? '',
      request: json['request'] ?? '',
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
      'user': user,
      'comment': comment,
      'praying': praying,
      'urgent': urgent,
    };
  }

  PrayerRequest copyWith({
    String? id,
    String? request,
    Map<String, dynamic>? user,
    List<String>? comment,
    List<String>? praying,
    bool? urgent,
  }) {
    return PrayerRequest(
      id: id ?? this.id,
      request: request ?? this.request,
      user: user ?? this.user,
      comment: comment ?? this.comment,
      praying: praying ?? this.praying,
      urgent: urgent ?? this.urgent,
    );
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
