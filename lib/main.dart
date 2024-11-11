import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/ui/pages/security/lock_page.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final pbCubit = PocketBaseServiceCubit(pref);
  final notificationCubit = NotificationCubit(pbCubit.state.pb);
  await notificationCubit.fetchNotifications();

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
          create: (context) => PrayerRequestCubit(pbCubit.state.pb),
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
