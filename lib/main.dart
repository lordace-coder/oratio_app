import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/bible_readings/bible_reading_service.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:oratio_app/services/bible_reading.dart';
import 'package:oratio_app/services/chat/db/chat_hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/prayer_requests/requests_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/constants.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/pages/security/lock_page.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? connectivitySubscription;

  ConnectivityCubit() : super(true) {
    monitorConnection();
  }

  void monitorConnection() {
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      if (result.first == ConnectivityResult.none) {
        emit(false);
      } else {
        emit(_checkInternetConnection());
      }
    });
  }

  bool _checkInternetConnection() {
    //TODO
    return true;
  }

  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(
    MessageModelAdapter(),
  ); // Generate this using build_runner

  final pref = await SharedPreferences.getInstance();
  final bibleService = BibleReadingService();
  bibleService.updateIfNeeded(fetchReadings);
  PocketBase? pb;
  try {
    pb = PocketBase(
      AppData.baseUrl,
      authStore: AsyncAuthStore(
        save: (String data) async => pref.setString('pb_auth', data),
        initial: pref.getString('pb_auth'),
      ),
    );
  } catch (e) {
    debugPrint('PocketBase initialization error: $e');
  }
  final repository = MessageRepository(
    pocketBase: pb!,
    messageBox: await Hive.openBox<MessageModel>('messages'),
  );
  final pbCubit = PocketBaseServiceCubit(pb);
  final notificationCubit = NotificationCubit(pbCubit.state.pb);
  try {
    await notificationCubit.fetchNotifications();
  } catch (e) {
    debugPrint('Notification fetch error: $e');
  }
  final appRouter = AppRouter(pref: pref);

  ChatService chatService = ChatService(pbCubit.state.pb);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityCubit(),
        ),
        BlocProvider(
          create: (context) => MessageCubit(
            pb: pb!,
            repository: repository,
          ),
        ),
        BlocProvider(
          create: (context) => pbCubit,
        ),
        BlocProvider(
          create: (context) {
            final chat = ChatCubit(chatService, pbCubit.state.pb);
            try {
              chat.loadRecentChats();
              chat.subscribeToMessages(context);
            } catch (e) {
              debugPrint('Chat initialization error: $e');
            }
            return chat;
          },
          lazy: false,
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
            try {
              postCubit.fetchPosts();
            } catch (e) {
              debugPrint('Post fetch error: $e');
            }
            return postCubit;
          },
        ),
      ],
      child: MainApp(
        appRouter: appRouter,
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Book Mass',
      builder: (context, child) => AppLock(
        enabled: appRouter.opened(),
        builder: (context, arg) => ScaffoldMessenger(
          child: BlocListener<ConnectivityCubit, bool>(
            listener: (context, hasConnection) {
              if (hasConnection) {
                try {
                  context.read<ChatCubit>().loadRecentChats();
                  context.read<NotificationCubit>().fetchNotifications();
                  context.read<NotificationCubit>().realtimeConnection();
                  context.read<PostCubit>().fetchPosts();
                } catch (e) {
                  debugPrint('Data refresh error: $e');
                }
              } else {
                NotificationService.showError('No internet connection');
              }
            },
            child: BlocBuilder<ConnectivityCubit, bool>(
              builder: (context, hasConnection) {
                if (!hasConnection) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: 16),
                          const Text(
                            'No Internet Connection',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<ConnectivityCubit>()
                                  .monitorConnection();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return child!;
              },
            ),
          ),
        ),
        lockScreenBuilder: (context) => const LockScreen(),
        backgroundLockLatency: const Duration(seconds: 9),
      ),
      color: AppColors.primary,
      routerConfig: appRouter.appRouter(),
      theme: ThemeData(fontFamily: 'Itim', primaryColor: AppColors.primary),
    );
  }
}
