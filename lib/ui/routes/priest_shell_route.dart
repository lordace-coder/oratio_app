import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/priest_bloc/priest_bloc.dart';

class PriestShellRoute extends StatelessWidget {
  final Widget child;

  const PriestShellRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PriestBloc(),
      child: child,
    );
  }
}
