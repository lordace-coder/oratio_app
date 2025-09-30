import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';

Future<List<PrayerCommunity>> getCommunities(BuildContext context,
    {VoidCallback? onError, String? filter}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  final List<PrayerCommunity> data = [];
  try {
    final results = await pb
        .collection('prayer_community')
        .getFullList(filter: filter, expand: 'leader');
    return results.map((i) {
      final img = pb.getFileUrl(i, i.getStringValue('image')).toString();
      return PrayerCommunity(
        community: i.getStringValue('community'),
        description: i.getStringValue('description'),
        leader: i.expand['leader']!.first,
        members: i.getListValue('members').length,
        id: i.id,
        allMembers: i.getListValue('members'),
        image: img.isEmpty ? null : img,
      );
    }).toList();
  } catch (e) {
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
    onError?.call();
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
    final data = await pb
        .collection('prayer_community')
        .getOne(communityId, expand: 'leader');
    final image = pb.getFileUrl(data, data.getStringValue('image')).toString();
    return PrayerCommunity(
      community: data.getStringValue('community'),
      description: data.getStringValue('description'),
      leader: data.expand['leader']!.first,
      members: data.getListValue('members').length,
      id: data.id,
      allMembers: data.getListValue('members'),
      image: image,
    );
  } catch (e) {
    print('error $e');
  }
  return null;
}

Future<RecordModel> getPost(BuildContext context,
    {VoidCallback? onError, required String postId}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  final data = await pb
      .collection('posts')
      .getOne(postId, expand: 'user, comments, community');
  return data;
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

Future<List<RecordModel>> findParish(BuildContext context,
    {VoidCallback? onError, required String search}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    final results = await pb.collection('parish').getList(
        perPage: 60, filter: 'name ~ "$search" || location ~ "$search"  ');
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

Future<RecordModel?> getParishGoingLive(PocketBase pb) async {
  try {
    final data = await pb.collection('parish').getList(filter: 'isLive = true');
    return data.items.first;
  } catch (e) {
    return null;
  }
}

Future<void> sendAnnoucement(BuildContext ctx, Map<String, String> data) async {
  final pb = getPocketBaseFromContext(ctx);
  try {
    await pb.collection("announcement").create(body: data);
    NotificationService.showInfo("Sent annoucement succesfully");
  } catch (e) {
    print("error occured sendin annoucement $e");
    NotificationService.showError('Error occured sending annoucement');
  }
}
