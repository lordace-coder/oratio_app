import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

