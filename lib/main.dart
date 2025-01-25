import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:hive/hive.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/widgets/prayer_requests.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/ads_bloc/ads_cubit.dart';
import 'package:oratio_app/bloc/bible_readings/bible_reading_service.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/bloc/transactions_cubit/transaction_cubit.dart';
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
import 'package:oratio_app/bloc/central_cubit/central_cubit.dart';
import 'package:flutter/foundation.dart';

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
      if (result == ConnectivityResult.none) {
        emit(false);
      } else {
        emit(await _checkInternetConnection());
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
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

  await Firebase.initializeApp();

  // OneSignal setup
  await OneSignal.Debug.setLogLevel(OSLogLevel.error);
  OneSignal.initialize('2e3b5f47-0603-448b-a864-f14fdecadbab');
  OneSignal.Notifications.requestPermission(true);
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  // Initialize Hive for local storage
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(
    MessageModelAdapter(),
  ); // Generate this using build_runner

  final pref = await SharedPreferences.getInstance();
  final bibleService = BibleReadingService();
  // Update Bible readings if needed
  bibleService.updateIfNeeded(fetchReadings);
  PocketBase? pb;
  
  try {
    pb = PocketBase(
      AppData.baseUrl,
      authStore: AsyncAuthStore(
          save: (String data) async => pref.setString('pb_auth', data),
          initial: pref.getString('pb_auth'),
          clear: () => pref.remove('pb_auth')),
    );
  } catch (e) {
    debugPrint('Error creating PocketBase instance: $e');
  }
  
  debugPrint('auth valid == ${pb?.authStore.isValid}');
  
  try {
    pb?.collection('users').authRefresh();
  } catch (e) {
    pb?.authStore.clear();
    debugPrint('Error refreshing PocketBase auth: $e');
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
    debugPrint('Error fetching notifications: $e');
  }
  final appRouter = AppRouter(pref: pref);

  ChatService chatService = ChatService(pbCubit.state.pb);

  final prayerRequestHelper = PrayerRequestHelper(pb);
  final postHelper = PostHelper(pb);
  final adsRepo = AdsRepo(pb);
  final prayerRequestService = PrayerRequestGroupService(pb);

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
          create: (context) => TransactionCubit(
            pocketBase: pbCubit.state.pb,
          ),
        ),
        BlocProvider(
          create: (context) {
            final chat = ChatCubit(chatService, pbCubit.state.pb);
            try {
              chat.loadRecentChats();
              chat.subscribeToMessages(context);
            } catch (e) {
              debugPrint(
                  'Error loading recent chats or subscribing to messages: $e');
            }
            return chat;
          },
          lazy: false,
        ),
        BlocProvider(create: (context) => AdsCubit(adsRepo)),
        BlocProvider(
          create: (context) => notificationCubit,
        ),
        BlocProvider<ProfileDataCubit>(
          create: (context) => ProfileDataCubit(pbCubit.state.pb),
        ),
        BlocProvider<PrayerRequestCubit>(
          create: (context) => PrayerRequestCubit(prayerRequestService),
        ),
        BlocProvider(
          create: (context) => CentralCubit(
            adsRepo: adsRepo,
            profileDataCubit: context.read<ProfileDataCubit>(),
            prayerRequestHelper: prayerRequestHelper,
            postHelper: postHelper,
            notificationCubit: context.read<NotificationCubit>(),
            messageCubit: context.read<MessageCubit>(),
            chatCubit: context.read<ChatCubit>(),
            pb: pb!,
          ),
        ),
      ],
      child: MainApp(appRouter: appRouter),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    connectWebSocket();
  }

  void connectWebSocket() {
    final pb = getPocketBaseFromContext(context);
    if (!pb.authStore.isValid || pb.authStore.model == null) {
      return;
    }
    final userId = pb.authStore.model.id;
    channel = WebSocketChannel.connect(
      Uri.parse('ws://bookmass.fly.dev/ws?uid=$userId'),
    );

    channel!.stream.listen(
      (message) {
        debugPrint('Received: $message');
      },
      onDone: () {
        debugPrint('WebSocket closed');
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
    );
  }

  Future<void> _initializeApp() async {
    final pb = getPocketBaseFromContext(context);
    if (!pb.authStore.isValid) {
      setState(() {
        _isInitialized = true;
      });
      return;
    }
    try {
      await context.read<CentralCubit>().initialize(context);
      await context.read<CentralCubit>().getFeeds();
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Book Mass',
      builder: (context, child) => AppLock(
        enabled: widget.appRouter.opened(),
        builder: (context, arg) => ScaffoldMessenger(
          child: BlocListener<ConnectivityCubit, bool>(
            listener: (context, hasConnection) {
              if (hasConnection) {
                try {
                  context.read<ChatCubit>().loadRecentChats();
                  context.read<NotificationCubit>().fetchNotifications();
                  context.read<NotificationCubit>().realtimeConnection();
                } catch (e) {}
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
      routerConfig: widget.appRouter.appRouter(),
      theme: ThemeData(fontFamily: 'Itim', primaryColor: AppColors.primary),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Image.asset("assets/images/app_logo.png",
              width: 180, height: 180, fit: BoxFit.cover),
        ),
      ),
    );
  }
}