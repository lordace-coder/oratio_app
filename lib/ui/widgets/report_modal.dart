import 'package:ace_toast/ace_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../models/report_model.dart';
import '../../services/reporting_service.dart';

class ReportModal extends StatefulWidget {
  final String contentId;
  final ContentType contentType;
  final String reportedUserId;
  final String? contentPreview;

  const ReportModal({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.reportedUserId,
    this.contentPreview,
  });

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  ReportType? selectedReportType;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.spam:
        return 'Spam';
      case ReportType.harassment:
        return 'Harassment or Bullying';
      case ReportType.inappropriateContent:
        return 'Inappropriate Content';
      case ReportType.hate:
        return 'Hate Speech';
      case ReportType.violence:
        return 'Violence or Threats';
      case ReportType.falseInformation:
        return 'False Information';
      case ReportType.other:
        return 'Other';
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.spam:
        return FontAwesomeIcons.envelopeCircleCheck;
      case ReportType.harassment:
        return FontAwesomeIcons.userSlash;
      case ReportType.inappropriateContent:
        return FontAwesomeIcons.eyeSlash;
      case ReportType.hate:
        return FontAwesomeIcons.heartCrack;
      case ReportType.violence:
        return FontAwesomeIcons.handFist;
      case ReportType.falseInformation:
        return FontAwesomeIcons.circleExclamation;
      case ReportType.other:
        return FontAwesomeIcons.flag;
    }
  }

  String _getContentTypeLabel() {
    switch (widget.contentType) {
      case ContentType.post:
        return 'Post';
      case ContentType.prayerRequest:
        return 'Prayer Request';
      case ContentType.message:
        return 'Message';
      case ContentType.comment:
        return 'Comment';
      case ContentType.user:
        return 'User';
    }
  }

  Future<void> _submitReport() async {
    if (selectedReportType == null) {
      NotificationService.showError('Please select a reason for reporting');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final currentUser = context.read<PocketBaseServiceCubit>().state.pb.authStore.model as RecordModel?;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final reportingService = ReportingService(pb);

      final result = await reportingService.submitReport(
        contentId: widget.contentId,
        contentType: widget.contentType,
        reportType: selectedReportType!,
        reporterId: currentUser.id,
        reportedUserId: widget.reportedUserId,
        additionalDetails: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
      );

      if (!mounted) return;

      // You can access the report data here: result['data']
      // Handle the upload or store locally as needed
      print('Report data: ${result['data']}');

      NotificationService.showSuccess('Report submitted successfully');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      NotificationService.showError('Failed to submit report: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            FontAwesomeIcons.flag,
                            color: Colors.red.shade400,
                            size: 24,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Report Content',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Report this ${_getContentTypeLabel().toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // Content Preview (if available)
                    if (widget.contentPreview != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.quoteLeft,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                widget.contentPreview!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                    ],

                    // Reason label
                    const Text(
                      'Why are you reporting this?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(12),
                  ],
                ),
              ),

              // Report type options
              ...ReportType.values.map((type) {
                final isSelected = selectedReportType == type;
                return InkWell(
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            selectedReportType = type;
                          });
                        },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade50 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.red.shade300
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getReportTypeIcon(type),
                          color: isSelected
                              ? Colors.red.shade600
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            _getReportTypeLabel(type),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.red.shade700 : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            FontAwesomeIcons.circleCheck,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const Gap(20),

              // Additional details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional details (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(12),
                    TextField(
                      controller: _detailsController,
                      enabled: !_isSubmitting,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Provide more information about this report...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isSubmitting
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
                                'Submit Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the report modal
Future<bool?> showReportModal(
  BuildContext context, {
  required String contentId,
  required ContentType contentType,
  required String reportedUserId,
  String? contentPreview,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReportModal(
      contentId: contentId,
      contentType: contentType,
      reportedUserId: reportedUserId,
      contentPreview: contentPreview,
    ),
  );
}
