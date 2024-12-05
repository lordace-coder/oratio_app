import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:pocketbase/pocketbase.dart';

String? getProfilePic(BuildContext ctx, {required RecordModel user}) {
  if (user.getStringValue("avatar").isEmpty) {
    return null;
  }
  final pb = ctx.read<PocketBaseServiceCubit>().state.pb;
  return pb.getFileUrl(user, user.getStringValue("avatar")).toString();
}
