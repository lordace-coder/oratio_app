import 'package:pocketbase/pocketbase.dart';
import '../models/report_model.dart';

class ReportingService {
  final PocketBase pb;

  ReportingService(this.pb);

  /// Simulates reporting content with loading delay
  /// Returns the report data so you can handle the upload to your backend
  Future<Map<String, dynamic>> submitReport({
    required String contentId,
    required ContentType contentType,
    required ReportType reportType,
    required String reporterId,
    required String reportedUserId,
    String? additionalDetails,
  }) async {
    // Prepare report data
    final reportData = {
      'content_id': contentId,
      'content_type': contentType.name,
      'report_type': reportType.name,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'additional_details': additionalDetails ?? '',
      'status': 'pending', // pending, reviewed, resolved
    };

    try {
      // Uncomment when you create the 'reports' collection in PocketBase
      final record = await pb.collection('reports').create(body: reportData);
      return record.toJson();
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  /// Marks content as spam (quick report)
  Future<Map<String, dynamic>> markAsSpam({
    required String contentId,
    required ContentType contentType,
    required String reporterId,
    required String reportedUserId,
  }) async {
    return await submitReport(
      contentId: contentId,
      contentType: contentType,
      reportType: ReportType.spam,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      additionalDetails: 'Marked as spam',
    );
  }

  /// Blocks a user
  Future<void> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      await pb.collection('users').update(pb.authStore.model.id, body: {
        'blocked_users+': blockedUserId,
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  /// Unblocks a user
  Future<bool> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      // Uncomment when you create the 'blocked_users' collection
      final records =
          await pb.collection("users").update(pb.authStore.model.id, body: {
        'blocked_users-': blockedUserId,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  /// Gets list of blocked users with their details
  Future<List<RecordModel>> getBlockedUsers(String userId) async {
    try {
      final user = await pb.collection('users').getOne(userId);
      final blockedUserIds = user.getListValue<String>('blocked_users');

      if (blockedUserIds.isEmpty) {
        return [];
      }

      // Fetch user details for each blocked user
      final blockedUsersData = <RecordModel>[];
      for (final blockedId in blockedUserIds) {
        try {
          final blockedUser = await pb.collection('users').getOne(blockedId);
          blockedUsersData.add(blockedUser);
        } catch (e) {
          // Skip if user not found
        }
      }

      return blockedUsersData;
    } catch (e) {
      throw Exception('Failed to get blocked users: $e');
    }
  }

  /// Checks if a user is blocked by another user
  Future<bool> isUserBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final user = await pb.collection('users').getOne(blockerId);
      final blockedUserIds = user.getListValue<String>('blocked_users');
      return blockedUserIds.contains(blockedUserId);
    } catch (e) {
      return false;
    }
  }

  /// Deletes user account
  Future<bool> deleteUserAccount(String userId) async {
    // Simulate network delay

    try {
 
      await pb.collection('users').delete(userId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
