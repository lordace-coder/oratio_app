// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/bright/pages/create_event.dart';
import 'package:oratio_app/ui/bright/pages/mass_booking_page.dart';
import 'package:oratio_app/ui/widgets/image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/ui/pages/auth/auth_wrapper.dart';
import 'package:oratio_app/ui/pages/auth/forgot_pw_page.dart';
import 'package:oratio_app/ui/pages/bible_reading_page.dart';
import 'package:oratio_app/ui/pages/create_prayer_request_page.dart';
import 'package:oratio_app/ui/pages/onboarding_page.dart';
import 'package:oratio_app/ui/pages/profile_page.dart';
import 'package:oratio_app/ui/pages/schedules_page.dart';
import 'package:oratio_app/ui/pages/settings_screen.dart';
import 'package:oratio_app/ui/pages/transaction_details.dart';
import 'package:oratio_app/ui/routes/route_names.dart';

import '../pages/pages.dart';

// shell_route_wrapper.dart
class ShellRouteWrapper extends StatefulWidget {
  final Widget child;

  const ShellRouteWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ShellRouteWrapper> createState() => _ShellRouteWrapperState();
}

class _ShellRouteWrapperState extends State<ShellRouteWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices(context);
    });
  }

  void _initializeServices(BuildContext context) {
    try {
      NotificationService.initialize(context);
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize NotificationService: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppRouter {
  final SharedPreferences pref;
  GoRouter? goRouter;
  AppRouter({
    required this.pref,
  });

  /// check if this is the first time
  bool opened() {
    return pref.getBool('opened') ?? false;
  }

  GoRouter appRouter() {
    if (goRouter == null) {
      String initialLocation = '/';
      if (!opened()) {
        initialLocation = '/auth/onboarding';
      }
      goRouter = GoRouter(
        redirectLimit: 2,
        initialLocation: initialLocation,
        redirect: (context, state) {
          final pb = context.read<PocketBaseServiceCubit>().state.pb;

          if (!pb.authStore.isValid && !state.fullPath!.contains('auth')) {
            return '/auth/login';
          }
          return null;
        },
        routes: [
          ShellRoute(
              builder: (context, state, child) =>
                  ShellRouteWrapper(child: child),
              routes: [
                GoRoute(
                  path: '/',
                  name: RouteNames.homePage,
                  builder: (context, state) =>
                      const AuthListener(child: HomePage()),
                ),
                GoRoute(
                  path: '/settings',
                  name: RouteNames.settingsPage,
                  builder: (context, state) => const SettingsPage(),
                ),
                GoRoute(
                  path: '/profilevisitor/:id',
                  name: RouteNames.profilepagevisitor,
                  builder: (context, state) => AuthListener(
                      child: ProfileVisitorPage(
                    id: state.pathParameters['id'].toString(),
                  )),
                ),
                GoRoute(
                  path: '/connect',
                  name: RouteNames.connect,
                  builder: (context, state) => const ConnectPage(),
                ),
                 GoRoute(
                  path: '/image-viewer',
                  name: RouteNames.imageView,
                  builder: (context, state) =>   ImageViewer(),
                ),
                GoRoute(
                  path: '/profilepage',
                  name: RouteNames.profile,
                  builder: (context, state) =>
                      const AuthListener(child: ProfilePage()),
                ),
                GoRoute(
                  path: '/auth/forgotpwpage',
                  name: RouteNames.forgotpwpage,
                  builder: (context, state) =>
                      const AuthListener(child: ForgotPasswordPage()),
                ),
                GoRoute(
                  path: '/${RouteNames.notifications}',
                  name: RouteNames.notifications,
                  builder: (context, state) =>
                      const AuthListener(child: NotificationPage()),
                ),
                GoRoute(
                  path: '/auth/login',
                  name: RouteNames.login,
                  builder: (context, state) =>
                      const AuthListener(child: LoginPage()),
                ),
                GoRoute(
                  path: '/auth/signup',
                  name: RouteNames.signup,
                  builder: (context, state) =>
                      const AuthListener(child: SignupPage()),
                ),
                GoRoute(
                  path: '/community',
                  name: RouteNames.communitypage,
                  builder: (context, state) =>
                      const AuthListener(child: CommunityPage()),
                ),
                GoRoute(
                  path: '/parishlistpage',
                  name: RouteNames.parishpage,
                  builder: (context, state) => const ParishListPage(),
                ),
                GoRoute(
                  path: '/auth/onboarding',
                  name: RouteNames.onboarding,
                  builder: (context, state) => const OnboardingScreen(),
                ),
                GoRoute(
                  path: '/${RouteNames.communityDetailPage}/:community',
                  name: RouteNames.communityDetailPage,
                  builder: (context, state) => PrayerCommunityDetail(
                    communityId: state.pathParameters['community'].toString(),
                  ),
                ),

                GoRoute(
                  path: '/mass',
                  name: RouteNames.mass,
                  builder: (context, state) => const MassBookingPage(),
                ),

                GoRoute(
                  path: '/create-event-page',
                  name: RouteNames.createEvent,
                  builder: (context, state) => const CreateEventPage(),
                ),
                GoRoute(
                  path: '/parishdetails:id',
                  name: RouteNames.parishlanding,
                  builder: (context, state) => ParishLandingPage(
                    parishId: state.pathParameters['id'].toString(),
                  ),
                ),

                GoRoute(
                  path: '/${RouteNames.createPrayerRequest}',
                  name: RouteNames.createPrayerRequest,
                  builder: (context, state) => const CreatePrayerRequestPage(),
                ),
                GoRoute(
                  path: '/${RouteNames.transactionsPage}',
                  name: RouteNames.transactionsPage,
                  builder: (context, state) => const TransactionPage(),
                ),
                GoRoute(
                  path: '/${RouteNames.schedule}',
                  name: RouteNames.schedule,
                  builder: (context, state) => const SchedulesPage(),
                ),

                GoRoute(
                  path: '/${RouteNames.transactionDetails}',
                  name: RouteNames.transactionDetails,
                  builder: (context, state) => const TransactionDetailsPage(),
                ),
                GoRoute(
                  path: '/${RouteNames.scanQr}',
                  name: RouteNames.scanQr,
                  builder: (context, state) => const ScanQrPage(),
                ),
                GoRoute(
                  path: '/${RouteNames.readingPage}',
                  name: RouteNames.readingPage,
                  builder: (context, state) => const BibleReadingPage(),
                ),

                // priest routes
                GoRoute(
                    path: '/priest/dashboard',
                    name: RouteNames.dashboard,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        transitionDuration: const Duration(seconds: 1),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: const DashboardPage(),
                          );
                        },
                        child: const DashboardPage(),
                      );
                    }),
                GoRoute(
                  path: '/priest/${RouteNames.massRequests}',
                  name: RouteNames.massRequests,
                  builder: (context, state) => const BookedMassesPage(),
                ),
                GoRoute(
                  path: '/priest/${RouteNames.createCommunityPage}',
                  name: RouteNames.createCommunityPage,
                  builder: (context, state) =>
                      const PrayerCommunityCreationPage(),
                ),
              ])
        ],
      );
      return goRouter!;
    }
    return goRouter!;
  }
}

/// Marks that app has been opened
Future markOpened() async {
  final pref = await SharedPreferences.getInstance();
  pref.setBool('opened', true);
}
