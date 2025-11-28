import 'package:ace_toast/ace_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/reporting_service.dart';
import '../../models/report_model.dart';

class BlockUserDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const BlockUserDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isBlocking = false;

  Future<void> _blockUser() async {
    setState(() {
      _isBlocking = true;
    });

    try {
      final pb = getPocketBaseFromContext(context);
      final currentUser = pb.authStore.model as RecordModel;

      final reportingService = ReportingService(pb);

      final result = await reportingService.blockUser(
        blockerId: currentUser.id,
        blockedUserId: widget.userId,
      );

      if (!mounted) return;

      // You can access the block data here: result['data']

      NotificationService.showSuccess('${widget.userName} has been blocked');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      NotificationService.showError('Failed to block user: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isBlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.userSlash,
              color: Colors.orange.shade600,
              size: 32,
            ),
          ),
          const Gap(20),
          Text(
            'Block ${widget.userName}?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            'They will no longer be able to:\n\n'
            '• Send you messages\n'
            '• See your posts and activity\n'
            '• Interact with your content',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isBlocking ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBlocking ? null : _blockUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isBlocking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Block',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to show block user dialog
Future<bool?> showBlockUserDialog(
  BuildContext context, {
  required String userId,
  required String userName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => BlockUserDialog(
      userId: userId,
      userName: userName,
    ),
  );
}

// Quick spam dialog
Future<void> showSpamDialog(
  BuildContext context, {
  required String contentId,
  required String contentType,
  required String reportedUserId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.ban,
              color: Colors.red.shade600,
              size: 32,
            ),
          ),
          const Gap(20),
          const Text(
            'Mark as Spam?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            'This will report the content as spam and help us keep the community safe.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Mark as Spam',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ],
    ),
  );

  if (result == true && context.mounted) {
    try {
      final pb = getPocketBaseFromContext(context);
      final currentUser = pb.authStore.model as RecordModel?;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final reportingService = ReportingService(pb);

      // Show loading - capture the context for the loading dialog
      final loadingContext = context;
      showDialog(
        context: loadingContext,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      ContentType enumContentType;
      switch (contentType) {
        case 'post':
          enumContentType = ContentType.post;
          break;
        case 'prayer_request':
          enumContentType = ContentType.prayerRequest;
          break;
        case 'message':
          enumContentType = ContentType.message;
          break;
        case 'user':
          enumContentType = ContentType.user;
          break;
        case 'comment':
          enumContentType = ContentType.comment;
          break;
        default:
          enumContentType = ContentType.post;
      }

      final spamResult = await reportingService.markAsSpam(
        contentId: contentId,
        contentType: enumContentType,
        reporterId: currentUser.id,
        reportedUserId: reportedUserId,
      );

      if (!loadingContext.mounted) return;

      // Close loading dialog
      Navigator.of(loadingContext, rootNavigator: true).pop();

      print('Spam report data: ${spamResult['data']}');
      NotificationService.showSuccess('Marked as spam successfully');
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog using root navigator
      Navigator.of(context, rootNavigator: true).pop();
      NotificationService.showError('Failed to mark as spam: ${e.toString()}');
    }
  }
}
