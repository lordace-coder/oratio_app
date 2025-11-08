import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:hive/hive.dart';
import 'package:oratio_app/models/contact_model.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/splash.dart';
import 'package:oratio_app/ui/widgets/prayer_requests.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:ace_toast/ace_toast.dart';
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
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/constants.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oratio_app/bloc/central_cubit/central_cubit.dart';
import 'package:oratio_app/bloc/meta_data_cubit.dart';

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
    _checkInitialConnection();
    monitorConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        emit(false);
      } else {
        emit(await _checkInternetConnection());
      }
    } catch (e) {
      debugPrint('Error checking initial connection: $e');
      emit(false);
    }
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
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Internet connection check failed: $e');
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
  // for ios status bar display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

  // OneSignal setup
  OneSignal.Debug.setLogLevel(OSLogLevel.error);
  OneSignal.initialize('2e3b5f47-0603-448b-a864-f14fdecadbab');
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault(); // Prevent notification from displaying
  });
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  // Initialize Hive for local storage
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(
    MessageModelAdapter(),
  ); // Generate this using build_runner
  Hive.registerAdapter(ContactModelAdapter());

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
  final notificationCubit = NotificationCubit(pb);
  try {
    await notificationCubit.fetchNotifications();
  } catch (e) {
    debugPrint('Error fetching notifications: $e');
  }
  final appRouter = AppRouter(pref: pref);

  ChatService chatService = ChatService(pbCubit.state.pb);

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
            postHelper: postHelper,
            notificationCubit: context.read<NotificationCubit>(),
            messageCubit: context.read<MessageCubit>(),
            chatCubit: context.read<ChatCubit>(),
            pb: pb!,
          ),
        ),
        BlocProvider(
          create: (context) => MetaDataCubit({}),
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
  Timer? _reconnectTimer;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    connectWebSocket();
    initDeepLinks();
  }

  void connectWebSocket() {
    final pb = getPocketBaseFromContext(context);
    if (!pb.authStore.isValid || pb.authStore.model == null) {
      return;
    }
    // connect all realtime listeners
    context.read<CentralCubit>().realTimeInit(context);
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
        _scheduleReconnect();
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      connectWebSocket();
    });
  }

  Future<void> _initializeApp() async {
    final pb = getPocketBaseFromContext(context);
    if (!pb.authStore.isValid) {
      setState(() {
        _isInitialized = true;
      });
      widget.appRouter.appRouter().push('/auth/login');
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
    _reconnectTimer?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _appLinks.getLatestLinkString().then((val) {});
    // Handle links
    String editedUrl = '';
    _appLinks.stringLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      editedUrl = uri
          .replaceFirst('https://www.cathsapp.ng/app', '')
          .replaceFirst('https://cathsapp.ng/app', '');
      openAppLink(editedUrl);
    });
  }

  void openAppLink(String path) {
    widget.appRouter.appRouter().push(path);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Book Mass',
      builder: (context, child) => ScaffoldMessenger(
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
          child: child!,
        ),
      ),
      color: AppColors.primary,
      routerConfig: widget.appRouter.appRouter(),
      theme: ThemeData(fontFamily: 'Itim', primaryColor: AppColors.primary),
    );
  }
}
