import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/ui/pages/auth/auth_wrapper.dart';
import 'package:oratio_app/ui/pages/auth/forgot_pw_page.dart';
import 'package:oratio_app/ui/pages/bible_reading_page.dart';
import 'package:oratio_app/ui/pages/chat_page.dart';
import 'package:oratio_app/ui/pages/profile_page.dart';
import 'package:oratio_app/ui/pages/schedules_page.dart';
import 'package:oratio_app/ui/pages/transaction_details.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/pages/settings_screen.dart';

import '../pages/pages.dart';

final appRouter = GoRouter(
  redirectLimit: 2,
  redirect: (context, state) {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    if (!pb.authStore.isValid && !state.fullPath!.contains('auth')) {
      print(state.fullPath);
      return '/auth/login';
    }

    print([state.fullPath, pb.authStore.isValid]);

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.homePage,
      builder: (context, state) => const AuthListener(child: HomePage()),
    ),
    GoRoute(
      path: '/settings',
      name: RouteNames.settingsPage,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/profilevisitor',
      name: RouteNames.profilepagevisitor,
      builder: (context, state) =>
          const AuthListener(child: ProfileVisitorPage()),
    ),
    GoRoute(
      path: '/connect',
      name: RouteNames.connect,
      builder: (context, state) => const ConnectPage(),
    ),
    GoRoute(
      path: '/profilepage',
      name: RouteNames.profile,
      builder: (context, state) => const AuthListener(child: ProfilePage()),
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
      builder: (context, state) => const AuthListener(child: LoginPage()),
    ),
    GoRoute(
      path: '/auth/signup',
      name: RouteNames.signup,
      builder: (context, state) => const AuthListener(child: SignupPage()),
    ),
    GoRoute(
      path: '/community',
      name: RouteNames.communitypage,
      builder: (context, state) => const AuthListener(child: CommunityPage()),
    ),
    GoRoute(
      path: '/parishlistpage',
      name: RouteNames.parishpage,
      builder: (context, state) => const ParishListPage(),
    ),
    GoRoute(
      path: '/${RouteNames.communityDetailPage}',
      name: RouteNames.communityDetailPage,
      builder: (context, state) => const PrayerCommunityDetail(),
    ),
    GoRoute(
      path: '/paymentsuccesfull/:status',
      name: RouteNames.paymentSuccesful,
      builder: (context, state) => const PaymentSuccesful(
        paymentStatus: PaymentStatus.succesful,
      ),
    ),
    GoRoute(
      path: '/mass',
      name: RouteNames.mass,
      builder: (context, state) => const MassBookingPage(),
    ),
    GoRoute(
      path: '/parishdetails',
      name: RouteNames.parishlanding,
      builder: (context, state) => const ParishLandingPage(),
    ),
    GoRoute(
      path: '/massDetail',
      name: RouteNames.massDetail,
      builder: (context, state) => const MassDetailPage(),
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
      path: '/${RouteNames.chatDetailPage}',
      name: RouteNames.chatDetailPage,
      builder: (context, state) => const ChatPage(),
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
    GoRoute(
      path: '/${RouteNames.prayerPage}',
      name: RouteNames.prayerPage,
      builder: (context, state) => const PrayerPage(),
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
                child: DashboardPage(),
              );
            },
            child: DashboardPage(),
          );
        })
  ],
);
