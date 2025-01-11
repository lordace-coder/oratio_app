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

Future<List<RecordModel>> getTransactions(BuildContext ctx) async {
  final pb = getPocketBaseFromContext(ctx);
  final data = await pb.collection("transaction_history_parish").getList();
  return data.items;
}

Future<void> acceptMassRequest(BuildContext ctx, String id) async {
  final pb = getPocketBaseFromContext(ctx);
  await pb.collection('mass_booking').update(id, body: {'confirmed': true});
}

Future<void> declineMassRequest(BuildContext ctx, String id) async {
  final pb = getPocketBaseFromContext(ctx);
  await pb.collection('mass_booking').update(id, body: {'confirmed': false});
}
