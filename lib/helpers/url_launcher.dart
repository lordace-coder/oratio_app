import 'package:oratio_app/helpers/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

const baseUrl = "https://cathsapp.ng";
void openTermsUrl(BuildContext context) async {
  if (await canLaunchUrl(Uri.parse('$baseUrl/terms-and-conditions'))) {
    launchUrl(Uri.parse('$baseUrl/terms-and-conditions'));
  } else {
    showError(context, message: 'Unable to open url on the app');
  }
}

void openPolicyUrl(BuildContext context) async {
  if (await canLaunchUrl(Uri.parse('$baseUrl/privacy-policy'))) {
    launchUrl(Uri.parse('$baseUrl/privacy-policy'));
  } else {
    showError(context, message: 'Unable to open url on the app');
  }
}
