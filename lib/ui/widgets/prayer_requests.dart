import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/pages/prayer_detail.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class UserPrayerRequestGroup {
  final RecordModel user;
  final List<PrayerRequest> prayerRequests;
  final DateTime latestRequestTime;

  UserPrayerRequestGroup({
    required this.user,
    required this.prayerRequests,
    required this.latestRequestTime,
  });
}

class PrayerRequestGroupService {
  final PocketBase pb;

  PrayerRequestGroupService(this.pb);

  /// Fetches and groups prayer requests by user, sorted by most recent request
  Future<List<UserPrayerRequestGroup>> getGroupedPrayerRequests() async {
    try {
      final currentUserId = pb.authStore.model.id;

      // Fetch all prayer requests for accessible users
      final resultList = await pb.collection('prayer_requests').getList(
            filter:
                'user.followers ~ "$currentUserId" || user.id = "$currentUserId"',
            expand: 'user',
            sort: '-created', // Sort by newest first
            perPage: 200, // Adjust as needed
          );

      // Create a map to group prayer requests by user
      final Map<String, List<PrayerRequest>> requestsByUser = {};
      final Map<String, RecordModel> userMap = {};
      final Map<String, DateTime> latestRequestTimeByUser = {};

      // Process each prayer request
      for (var record in resultList.items) {
        final prayerRequest = PrayerRequest(
          comment: record.getListValue('comment'),
          id: record.id,
          praying: record.getListValue('praying'),
          request: record.getStringValue('request'),
          urgent: record.getBoolValue('urgent'),
          user: record.expand['user']!.first,
          created: record.created,
        );

        final userId = prayerRequest.user.id;

        // Store user information
        userMap[userId] = prayerRequest.user;

        // Update or initialize prayer requests list for this user
        requestsByUser.putIfAbsent(userId, () => []).add(prayerRequest);

        // Update latest request time for this user
        final requestTime = DateTime.parse(prayerRequest.created);
        if (!latestRequestTimeByUser.containsKey(userId) ||
            requestTime.isAfter(latestRequestTimeByUser[userId]!)) {
          latestRequestTimeByUser[userId] = requestTime;
        }
      }

      // Convert to list of UserPrayerRequestGroup and sort by latest request
      final groupedList = requestsByUser.entries.map((entry) {
        return UserPrayerRequestGroup(
          user: userMap[entry.key]!,
          prayerRequests: entry.value
            ..sort((a, b) =>
                DateTime.parse(b.created).compareTo(DateTime.parse(a.created))),
          latestRequestTime: latestRequestTimeByUser[entry.key]!,
        );
      }).toList()
        ..sort((a, b) => b.latestRequestTime.compareTo(a.latestRequestTime));

      return groupedList;
    } catch (e) {
      print('Error fetching grouped prayer requests: $e');
      rethrow;
    }
  }

  /// Add a new prayer request and return updated groups
  Future<List<UserPrayerRequestGroup>> addPrayerRequest({
    required String request,
    required bool urgent,
  }) async {
    try {
      // Create the new prayer request
      await pb.collection('prayer_requests').create(body: {
        'request': request,
        'urgent': urgent,
        'user': pb.authStore.model.id,
      });

      // Fetch updated groups
      return await getGroupedPrayerRequests();
    } catch (e) {
      print('Error adding prayer request: $e');
      rethrow;
    }
  }

  /// Subscribe to real-time updates for prayer requests
}

class PrayerRequestCubit extends Cubit<List<UserPrayerRequestGroup>> {
  final PrayerRequestGroupService service;

  PrayerRequestCubit(this.service) : super([]) {
    _init();
  }
  void refresh() async {
    await _init();
  }

  Future<void> _init() async {
    emit(await service.getGroupedPrayerRequests());
  }

  Future<void> addPrayerRequest(String request, bool urgent) async {
    await service.addPrayerRequest(request: request, urgent: urgent);
    emit(await service.getGroupedPrayerRequests());
  }
}

class PrayerRequestGroupsList extends StatelessWidget {
  const PrayerRequestGroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerRequestCubit, List<UserPrayerRequestGroup>>(
      builder: (context, groups) {
        final currentUserId =
            context.read<PrayerRequestCubit>().service.pb.authStore.model.id;

        // Separate the current user's group
        UserPrayerRequestGroup? currentUserGroup;
        final otherGroups = <UserPrayerRequestGroup>[];

        for (var group in groups) {
          if (group.user.id == currentUserId) {
            currentUserGroup = group;
          } else {
            otherGroups.add(group);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 9),
              child: Text(
                'Prayers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    otherGroups.length + 1 + (currentUserGroup != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () async {
                          await context
                              .pushNamed(RouteNames.createPrayerRequest);
                        },
                        child: _StoryAvatar(
                          index: 0,
                          user:
                              RecordModel(), // Pass a dummy user or handle accordingly
                        ),
                      ),
                    );
                  }

                  if (index == 1 && currentUserGroup != null) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrayerRequestViewer(
                                otherPrayerRequests: groups,
                                prayerRequests:
                                    currentUserGroup!.prayerRequests,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: _StoryAvatar(
                          index: 1,
                          user: currentUserGroup.user,
                        ),
                      ),
                    );
                  }

                  final group = otherGroups[
                      index - 1 - (currentUserGroup != null ? 1 : 0)];

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrayerRequestViewer(
                              prayerRequests: group.prayerRequests,
                              initialIndex: 0,
                              otherPrayerRequests: groups,
                            ),
                          ),
                        );
                      },
                      child: _StoryAvatar(
                        index: index,
                        user: group.user,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final int index;
  final RecordModel user;

  const _StoryAvatar({required this.index, required this.user});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            // gradient: index == 0
            //     ? null
            //     : LinearGradient(
            //         colors: [
            //           AppColors.primary,
            //           Colors.green,
            //         ],
            //       ),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: index == 0
                ? null
                : getProfilePic(context, user: user) == null
                    ? null
                    : CachedNetworkImageProvider(getProfilePic(context, user: user)!),
            child: index == 0
                ? const Icon(Icons.add)
                : user.getStringValue('avatar').isEmpty
                    ? Text(
                        '  ${user.getStringValue('first_name')[0]}  ${user.getStringValue('last_name')[0]}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    : null,
          ),
        ),
        const Gap(4),
        Text(
          index == 0
              ? 'Say Prayer'
              : index == 1
                  ? 'You'
                  : user.getStringValue('username'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
