import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/central_cubit/central_cubit.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthListener extends StatefulWidget {
  const AuthListener({super.key, required this.child});

  final Widget child;

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = context.read<PocketBaseServiceCubit>().state;
      final pb = state.pb;

      _authSubscription = pb.authStore.onChange.listen((event) {
        if (!mounted) return;

        if (!pb.authStore.isValid) {
          context.pushNamed(RouteNames.login);

        } else {
          if (GoRouter.of(context).state?.fullPath?.contains('auth') ?? false) {
            OneSignal.login(pb.authStore.model.id);
            context.read<CentralCubit>().initialize(context);

            context.pushNamed(RouteNames.homePage);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
