import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_state.dart';
import 'package:oratio_app/helpers/user.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/pages/prayer_detail.dart';
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
  Stream<List<UserPrayerRequestGroup>> subscribeToUpdates() async* {
    try {
      // Initial data
      yield await getGroupedPrayerRequests();

      // Subscribe to real-time updates
      final controller = StreamController<List<UserPrayerRequestGroup>>();

      // Initial data
      controller.add(await getGroupedPrayerRequests());

      // Subscribe to real-time updates
      final unsubscribe =
          await pb.collection('prayer_requests').subscribe('*', (e) async {
        // Add new grouped data whenever there's an update
        controller.add(await getGroupedPrayerRequests());
      });

      // Close the controller when the stream is cancelled
      controller.onCancel = () {
        unsubscribe();
        controller.close();
      };

      yield* controller.stream;
    } catch (e) {
      print('Error in subscription: $e');
      rethrow;
    }
  }
}

// Example usage with a StatefulWidget
class PrayerRequestGroupsList extends StatefulWidget {
  const PrayerRequestGroupsList({super.key});

  @override
  _PrayerRequestGroupsListState createState() =>
      _PrayerRequestGroupsListState();
}

class _PrayerRequestGroupsListState extends State<PrayerRequestGroupsList> {
  late PrayerRequestGroupService service;
  late Stream<List<UserPrayerRequestGroup>> groupsStream;

  @override
  void initState() {
    super.initState();
    service = PrayerRequestGroupService(getPocketBaseFromContext(context));
    groupsStream = service.subscribeToUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserPrayerRequestGroup>>(
      stream: groupsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(
              child: Center(
                  child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Loading Prayers...'),
          )));
        }

        final groups = snapshot.data!;

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
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    if (index == 0) {
                      _StoryAvatar(
                        index: 1,
                        user: getPocketBaseFromContext(context).authStore.model,
                      );
                    }
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
                                ),
                              ),
                            );
                          },
                          child: _StoryAvatar(
                            index: index,
                            user: group.user,
                          )),
                    );
                  }),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: index == 0
                ? null
                : LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: getProfilePic(context, user: user) == null
                ? null
                : NetworkImage(getProfilePic(context, user: user)!),
            child: index == 0
                ? const Icon(Icons.add)
                : user.getStringValue('avatar').isEmpty
                    ? Text(
                        String.fromCharCode(65 + index),
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    : null,
          ),
        ),
        const Gap(4),
        Text(
          index == 0 ? 'Say Prayer' : user.getStringValue('username'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
