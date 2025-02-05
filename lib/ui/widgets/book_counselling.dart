import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/booking_requests.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:pocketbase/pocketbase.dart';

class Counselor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final String bio;
  final RecordModel record;
  Counselor({
    required this.record,
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.bio,
  });
}

class CounselorSelectionModal extends StatefulWidget {
  const CounselorSelectionModal({super.key});

  @override
  State<CounselorSelectionModal> createState() =>
      _CounselorSelectionModalState();
}

class _CounselorSelectionModalState extends State<CounselorSelectionModal> {
  bool isLoading = true;
  bool isSubmitting = false;
  String? error;
  List<Counselor> counselors = [];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  Future<void> _loadCounselors() async {
    try {
      final pb = getPocketBaseFromContext(context);
      final records = await fetchCounselors(pb);
      setState(() {
        counselors = records
            .map((record) => Counselor(
                  id: record.id,
                  record: record,
                  name: getFullName(record),
                  specialization:
                      record.data['specialization'] ?? 'General Counseling',
                  imageUrl:
                      record.data['avatar'] ?? 'assets/default_avatar.png',
                  bio: record.data['bio'] ?? 'No bio available',
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load counselors. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _sendCounselingRequest(Counselor counselor) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final pb = getPocketBaseFromContext(context);
      final data = {
        'counselor': counselor.id,
        'user': getUser(context).id,
        'message': messageController.text,
        'status': 'pending',
        'created': DateTime.now().toIso8601String(),
      };

      await pb.collection('counseling_requests').create(body: data);

      // Show success dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pop(); // Close the message modal
        _showSuccessDialog(counselor);
      }
    } catch (e) {
      setState(() {
        error = 'Failed to send request. Please try again.';
        isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog(Counselor counselor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Request Sent to ${counselor.name}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you once they respond to your request.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Select a Counselor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading counselors...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        error = null;
                        isLoading = true;
                      });
                      _loadCounselors();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: counselors.length,
                itemBuilder: (context, index) {
                  final counselor = counselors[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          try {
                            await requestCounselling(
                                getPocketBaseFromContext(context),
                                counselor.id);
                            context.pushNamed(RouteNames.chatDetailPage,
                                pathParameters: {
                                  "profile": Profile(
                                          community: [],
                                          user: counselor.record,
                                          parish: [],
                                          userId: counselor.id,
                                          contact: counselor.record
                                              .getStringValue('phone_number'))
                                      .toJsonString()
                                });
                          } catch (e) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider(
                                    getPocketBaseFromContext(context)
                                        .getFileUrl(counselor.record,
                                            counselor.imageUrl)
                                        .toString()),
                                backgroundColor: Colors.grey[200],
                                child: counselor.imageUrl.startsWith('assets/')
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      counselor.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      counselor.specialization,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
