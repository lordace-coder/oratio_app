import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/services/reporting_service.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ace_toast/ace_toast.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late PocketBase pb;
  late ReportingService reportingService;
  List<RecordModel> blockedUsers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    reportingService = ReportingService(pb);
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final currentUser = pb.authStore.model as RecordModel;
      final result = await reportingService.getBlockedUsers(currentUser.id);

      setState(() {
        blockedUsers = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(String blockedUserId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final currentUser = pb.authStore.model as RecordModel;
      await reportingService.unblockUser(
        blockerId: currentUser.id,
        blockedUserId: blockedUserId,
      );

      if (mounted) {
        NotificationService.showSuccess('$userName has been unblocked');
        _loadBlockedUsers(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError('Failed to unblock user: $e');
      }
    }
  }

  String? _getAvatarUrl(RecordModel user) {
    try {
      final avatar = user.getStringValue('avatar');
      if (avatar.isEmpty) return null;

      return pb.getFileUrl(user, avatar).toString();
    } catch (e) {
      return null;
    }
  }

  String _getFullName(RecordModel user) {
    final firstName = user.getStringValue('first_name');
    final lastName = user.getStringValue('last_name');
    return '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Blocked Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load blocked users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBlockedUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (blockedUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Blocked Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t blocked anyone yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: blockedUsers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 72,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final blockedUser = blockedUsers[index];

          final avatarUrl = _getAvatarUrl(blockedUser);
          final firstName = blockedUser.getStringValue('first_name');
          final lastName = blockedUser.getStringValue('last_name');
          final username = blockedUser.getStringValue('username');
          final initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
          final fullName = _getFullName(blockedUser);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: avatarUrl == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            title: Text(
              fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () => _unblockUser(blockedUser.id, fullName),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Unblock'),
            ),
          );
        },
      ),
    );
  }
}
