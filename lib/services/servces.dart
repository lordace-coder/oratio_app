import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:pocketbase/pocketbase.dart';

RecordModel getUser(BuildContext ctx) =>
    ctx.read<PocketBaseServiceCubit>().state.pb.authStore.model;

bool isParishMember(
    {required RecordModel church, required BuildContext context}) {
  return church.getListValue('members').contains(getUser(context).id);
}


bool isCommunityMember(
    {required RecordModel community, required BuildContext context}) {
  return community.getListValue('members').contains(getUser(context).id);
}
