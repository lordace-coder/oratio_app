import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/ui/pages/security/lock_page.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final pbCubit = PocketBaseServiceCubit(pref);
  final notificationCubit = NotificationCubit(pbCubit.state.pb);
   await notificationCubit.realtimeConnection();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => pbCubit,
        ),
        BlocProvider(
          create: (context) => notificationCubit,
        ),
        BlocProvider(
          lazy: false,
          create: (context) {
            final postCubit = PostCubit(pbCubit.state.pb);
            postCubit.fetchPosts();
            return postCubit;
          },
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Wait for the widget to be fully initialized
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Book Mass',
      builder: (context, child) => AppLock(
        builder: (context, arg) => child!,
        lockScreenBuilder: (context) => const LockScreen(),
        backgroundLockLatency: const Duration(seconds: 30),
      ),
      color: AppColors.primary,
      routerConfig: appRouter,
      theme: ThemeData(fontFamily: 'Itim', primaryColor: AppColors.primary),
    );
  }
}
