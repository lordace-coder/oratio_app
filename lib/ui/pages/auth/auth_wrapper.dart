import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/ui/routes/route_names.dart';

class AuthListener extends StatefulWidget {
  const AuthListener({super.key, required this.child});
  final Widget child;
  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PocketBaseServiceCubit>().state;
      final pb = state.pb;

      // Set up auth listener
      pb.authStore.onChange.listen((event) {
        if (!pb.authStore.isValid) {
          context.pushNamed(RouteNames.login);
        } else {
          context.pushNamed(RouteNames.homePage);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
