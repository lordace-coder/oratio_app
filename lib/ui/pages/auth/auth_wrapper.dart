import 'package:flutter/material.dart';


class AuthListener extends StatelessWidget {
  ///handles navigation when a user is Authenticated or Logged out

  const AuthListener({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
