import 'package:go_router/go_router.dart';
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
  ],
);
