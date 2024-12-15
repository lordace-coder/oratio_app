import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:pocketbase/pocketbase.dart';

PocketBase getPocketBaseFromContext(BuildContext context) {
  return context.read<PocketBaseServiceCubit>().state.pb;
}

Future<void> sendWithdrawalRequest(
    BuildContext ctx, Map<String, dynamic> data) async {
  final pb = getPocketBaseFromContext(ctx);
  await pb.collection('withdrawal_request').create(body: data);
}