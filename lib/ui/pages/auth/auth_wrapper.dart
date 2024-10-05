import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

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
