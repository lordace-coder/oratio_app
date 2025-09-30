import 'package:flutter/material.dart';
import 'package:ace_toast/ace_toast.dart';

void showError(BuildContext context, {required String message}) {
  NotificationService.showError(message, duration: const Duration(seconds: 4));
}

void showSuccess(BuildContext context, {required String message}) {
  NotificationService.showSuccess(message,
      duration: const Duration(seconds: 4));
}
