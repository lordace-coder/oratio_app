import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:pocketbase/pocketbase.dart';

Future<List<PrayerCommunity>> getCommunities(BuildContext context,
    {VoidCallback? onError}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  final List<PrayerCommunity> data = [];
  try {
    final results = await pb.collection('prayer_community').getFullList();
    return results
        .map((i) => PrayerCommunity(
              community: i.getStringValue('community'),
              description: i.getStringValue('description'),
              leader: {},
              members: i.getListValue('members').length,
              id: i.id,
            ))
        .toList();
  } catch (e) {
    print(e);
    onError?.call();
  }
  return data;
}

Future joinCommunity(BuildContext context,
    {VoidCallback? onError, required String communityId}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final community =
        await pb.collection('prayer_community').update(communityId, body: {
      'members+': (pb.authStore.model as RecordModel).id,
    });
    showSuccess(context,
        message: 'Welcome to ${community.getStringValue('community')}');
  } catch (e) {
    print('error $e');
    showError(context, message: 'Sorry something went wrong');
  }
}

Future<String> getUserBalance(String userId, PocketBase pb) async {
  try {
    final wallet = await pb.collection('users').getOne(userId);
    return "₦${wallet.getDoubleValue('wallet')}";
  } catch (e) {}
  return 'loading error';
}

Future<PrayerCommunity?> getCommunity(BuildContext context,
    {VoidCallback? onError, required String communityId}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final data = await pb.collection('prayer_community').getOne(
          communityId,
        );
    return PrayerCommunity(
      community: data.getStringValue('community'),
      description: data.getStringValue('description'),
      leader: {},
      members: data.getListValue('members').length,
      id: data.id,
    );
  } catch (e) {
    print('error $e');
  }
  return null;
}

Future<List<RecordModel>> getParishList(
  BuildContext context, {
  VoidCallback? onError,
  int page = 1,
}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final results =
        await pb.collection('parish').getList(page: page, perPage: 60);
    print(results);
    return results.items;
  } catch (e) {
    print(e);
    onError?.call();
  }
  return [];
}

Future<RecordModel?> getParish(BuildContext context,
    {VoidCallback? onError, required String id}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final data = await pb.collection('parish').getOne(id, expand: 'priest');
    return data;
  } catch (e) {
    print('error $e');
  }
  return null;
}

Future joinParish(BuildContext context,
    {VoidCallback? onError, required String id}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final community = await pb.collection('parish').update(id, body: {
      'members+': (pb.authStore.model as RecordModel).id,
    });
    showSuccess(context,
        message: 'Welcome to ${community.getStringValue('name')}');
  } catch (e) {
    print('error $e');
    showError(context, message: 'Sorry something went wrong');
  }
}

Future<List<PrayerCommunity>> getFeaturedCommunities(BuildContext context,
    {VoidCallback? onError}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  final List<PrayerCommunity> data = [];
  try {
    final results = await pb
        .collection('prayer_community')
        .getFullList(expand: 'members', filter: '');
    return results
        .map((i) => PrayerCommunity(
              community: i.getStringValue('community'),
              description: i.getStringValue('description'),
              leader: {},
              members: i.getListValue('members').length,
              id: i.id,
            ))
        .toList();
  } catch (e) {
    final err = e as ClientException;
    NotificationService.showError('Error occured ${e.response['message']}',
        duration: const Duration(seconds: 4));
  }
  return data;
}

Future<List<RecordModel>> findParish(BuildContext context,
    {VoidCallback? onError, required String search}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final results = await pb.collection('parish').getList(
        perPage: 60, filter: 'name ~ "$search" || location ~ "$search"  ');
    print(results);
    return results.items;
  } catch (e) {
    print(e);
    onError?.call();
  }
  return [];
}

Future createPrayerRequest(PocketBase pb, Map<String, dynamic> data) async {
  await pb.collection('prayer_requests').create(body: data);
}

Future<void> sendOffering(BuildContext context,
    {required Map<String, String> data}) async {
  // create offering
  try {
    await context
        .read<PocketBaseServiceCubit>()
        .state
        .pb
        .collection("offerings")
        .create(body: data);
    NotificationService.showSuccess("Offering recieved, Remain blessed");
  } catch (e) {
    print(e);
    NotificationService.showError(
      "Error occured while paying offering",
      duration: Durations.extralong4,
    );
  }
}

Future<Map> getRandomBibleReading() async {
  final dio = Dio();
  final response = await dio.get('https://bible-api.com/?random=verse');
  return response.data as Map;
}
