enum ReportType {
  spam,
  harassment,
  inappropriateContent,
  hate,
  violence,
  falseInformation,
  other,
}

enum ContentType {
  post,
  prayerRequest,
  message,
  comment,
  user,
}

class ReportModel {
  final String id;
  final String contentId;
  final ContentType contentType;
  final ReportType reportType;
  final String? additionalDetails;
  final String reporterId;
  final String reportedUserId;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.reportType,
    this.additionalDetails,
    required this.reporterId,
    required this.reportedUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'content_type': contentType.name,
      'report_type': reportType.name,
      'additional_details': additionalDetails,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      contentId: json['content_id'] ?? '',
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['content_type'],
        orElse: () => ContentType.post,
      ),
      reportType: ReportType.values.firstWhere(
        (e) => e.name == json['report_type'],
        orElse: () => ReportType.other,
      ),
      additionalDetails: json['additional_details'],
      reporterId: json['reporter_id'] ?? '',
      reportedUserId: json['reported_user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class BlockedUser {
  final String id;
  final String blockerId;
  final String blockedUserId;
  final DateTime createdAt;

  BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blocker_id': blockerId,
      'blocked_user_id': blockedUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? '',
      blockerId: json['blocker_id'] ?? '',
      blockedUserId: json['blocked_user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
