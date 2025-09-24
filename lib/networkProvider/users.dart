import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:pocketbase/pocketbase.dart';

Future<void> followUser(BuildContext context,
    {required String targetUserId}) async {
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;
  try {
    await pb.collection('users').update(targetUserId, body: {
      'followers+': [pb.authStore.model.id]
    });
  } catch (e) {
    print('error following user $e');
  }
}

Future<List<RecordModel>> listUsers(BuildContext context,
    {int page = 1, String? filter}) async {
  final data = <RecordModel>[];
  final PocketBase pb = context.read<PocketBaseServiceCubit>().state.pb;

  try {
    final results = await pb
        .collection('users')
        .getList(query: {'order': '?'}, page: page, filter: filter);
    return results.items;
  } catch (e) {
    print('error $e');
  }
  return data;
}

bool isFollowing(String id, List followers) {
  return followers.contains(id);
}

String getFullName(RecordModel user) {
  return '${user.getStringValue('first_name')} ${user.getStringValue('last_name')}';
}
