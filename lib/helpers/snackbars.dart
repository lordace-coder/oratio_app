import 'package:flutter/material.dart';

void showError(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    showCloseIcon: true,
    backgroundColor: Colors.red,
  ));
}

void showSuccess(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    showCloseIcon: true,
    backgroundColor: Colors.green,
  ));
}
