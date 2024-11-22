import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/pages/security/lock_page.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart' as splash;

void main() async {
  var binding = WidgetsFlutterBinding.ensureInitialized();
  splash.FlutterNativeSplash.preserve(widgetsBinding: binding);
  final pref = await SharedPreferences.getInstance();
  final pbCubit = PocketBaseServiceCubit(pref);
  final notificationCubit = NotificationCubit(pbCubit.state.pb);
  try {
    await notificationCubit.fetchNotifications();
  } catch (e) {}
  splash.FlutterNativeSplash.remove();
  ChatService chatService = ChatService(pbCubit.state.pb);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => pbCubit,
        ),
        BlocProvider(
          create: (context) =>
              ChatCubit(chatService, pbCubit.state.pb)..loadRecentChats(),
        ),
        BlocProvider(
          create: (context) => notificationCubit,
        ),
        BlocProvider<ProfileDataCubit>(
          create: (context) => ProfileDataCubit(pbCubit.state.pb),
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
        backgroundLockLatency: const Duration(seconds: 6),
      ),
      color: AppColors.primary,
      routerConfig: appRouter,
      theme: ThemeData(fontFamily: 'Itim', primaryColor: AppColors.primary),
    );
  }
}
