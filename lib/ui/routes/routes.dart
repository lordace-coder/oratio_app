import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/pages/auth/forgot_pw_page.dart';
import 'package:oratio_app/ui/pages/profile_page.dart';
import 'package:oratio_app/ui/routes/route_names.dart';

import '../pages/pages.dart';

final appRouter = GoRouter(
  redirectLimit: 2,
  redirect: (context, state) {
    return null;

    // return '/auth/signup';
  },
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.homePage,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profilepage',
      name: RouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/forgotpwpage',
      name: RouteNames.forgotpwpage,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/${RouteNames.notifications}',
      name: RouteNames.notifications,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: '/auth/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/auth/signup',
      name: RouteNames.signup,
      builder: (context, state) => SignupPage(),
    ),
    GoRoute(
      path: '/community',
      name: RouteNames.communitypage,
      builder: (context, state) => const CommunityPage(),
    ),
    GoRoute(
      path: '/parishlistpage',
      name: RouteNames.parishpage,
      // ignore: prefer_const_constructors
      builder: (context, state) => ParishListPage(),
    ),
    GoRoute(
      path: '/mass',
      name: RouteNames.mass,
      // ignore: prefer_const_constructors
      builder: (context, state) => MassBookingPage(),
    ),
    GoRoute(
      path: '/massDetail',
      name: RouteNames.massDetail,
      builder: (context, state) => const MassDetailPage(),
    ),
  ],
);
