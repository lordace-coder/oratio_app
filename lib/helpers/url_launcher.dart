import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

void openTermsUrl(BuildContext context) async {
  final baseUrl = context.read<PocketBaseServiceCubit>().state.pb.baseUrl;
  if (await canLaunchUrl(Uri.parse('$baseUrl/terms'))) {
    launchUrl(Uri.parse('$baseUrl/terms.html'));
  } else {
    showError(context, message: 'Unable to open url on the app');
  }
}
