// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/bright/pages/create_event.dart';
import 'package:oratio_app/ui/bright/pages/mass_booking_page.dart';
import 'package:oratio_app/ui/pages/annoucement_page.dart';
import 'package:oratio_app/ui/pages/chat_page.dart';
import 'package:oratio_app/ui/pages/community_prayer/prayers_page.dart';
import 'package:oratio_app/ui/pages/create_new_post.dart';
import 'package:oratio_app/ui/pages/edit_profile_page.dart';
import 'package:oratio_app/ui/pages/post_detail_page.dart';
import 'package:oratio_app/ui/pages/share_bible_passage.dart';
import 'package:oratio_app/ui/pages/utils/book_appointment.dart';
import 'package:oratio_app/ui/pages/utils/book_retreat.dart';
import 'package:oratio_app/ui/routes/priest_shell_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ace_toast/ace_toast.dart';
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
        redirect: (context, state) async {
          final pb = getPocketBaseFromContext(context);
          print('router says ${state.fullPath!.contains('/auth')}');

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
                  builder: (context, state) => const SearchPage(),
                ),
                GoRoute(
                  path: '/contacts',
                  name: RouteNames.contacts,
                  builder: (context, state) => ContactsPage(),
                ),
                GoRoute(
                  path: '/createpost',
                  name: RouteNames.createPost,
                  builder: (context, state) => const CreatePostPage(),
                ),

                GoRoute(
                  path: '/profilepage',
                  name: RouteNames.profile,
                  builder: (context, state) =>
                      const AuthListener(child: ProfilePage()),
                ),
                GoRoute(
                  path: '/annoucementpage/:id',
                  name: RouteNames.annoucementPage,
                  builder: (context, state) => AuthListener(
                      child: AnnoucementPage(
                          id: state.pathParameters['id'].toString())),
                ),

                GoRoute(
                    path: '/community-live/:id',
                    name: RouteNames.communityLivePage,
                    builder: (context, state) => AuthListener(
                          child: CommunityLivePage(
                            communityId: state.pathParameters['id'].toString(),
                            isHost: false,
                          ),
                        )),
                GoRoute(
                  path: '/host/communit/:id',
                  name: RouteNames.hostCommunityLivePage,
                  builder: (context, state) => AuthListener(
                    child: CommunityLivePage(
                      communityId: state.pathParameters['id'].toString(),
                      isHost: true,
                    ),
                  ),
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
                  path: '/book-appointment',
                  name: RouteNames.bookAppointment,
                  builder: (context, state) =>
                      const AuthListener(child: AppointmentBookingPage()),
                ),
                GoRoute(
                  path: '/book-retreat/:id/:parishName',
                  name: RouteNames.bookRetreat,
                  builder: (context, state) => AuthListener(
                      child: RetreatBookingPage(
                    parishId: state.pathParameters['id'].toString(),
                    parishName: state.pathParameters['parishName'].toString(),
                  )),
                ),

                GoRoute(
                  path: '/share-passage',
                  name: RouteNames.shareBiblePassage,
                  builder: (context, state) {
                    return ShareBiblePassage(
                      heading: (state.extra as Map)['heading'],
                      verse: (state.extra as Map)['verse'],
                    );
                  },
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
                  path: '/${RouteNames.postDetailPage}/:post',
                  name: RouteNames.postDetailPage,
                  builder: (context, state) => PostDetailPage(
                    postId: state.pathParameters['post'].toString(),
                  ),
                ),
                // GoRoute(
                //   path: '/${RouteNames.liveMassPage}',
                //   name: RouteNames.liveMassPage,
                //   builder: (context, state) => const LiveMassPage(parishId: '',),
                // ),
                GoRoute(
                    path: '/editprofile',
                    name: RouteNames.editprofile,
                    builder: (context, state) => const EditProfilePage()),
                GoRoute(
                  path: '/mass',
                  name: RouteNames.mass,
                  builder: (context, state) => const MassBookingPage(),
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
                  path: '/${RouteNames.chatDetailPage}/:profile',
                  name: RouteNames.chatDetailPage,
                  builder: (context, state) => ChatPage(
                    profile: Profile.fromJsonString(
                        state.pathParameters['profile'].toString()),
                  ),
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
                  path: '/${RouteNames.communityPrayersPage}',
                  name: RouteNames.communityPrayersPage,
                  builder: (context, state) {
                    final prayer = state.extra as Map<String, String>;
                    return PrayersPage(
                      prayerTitle: prayer['title'].toString(),
                      prayerText: prayer['prayer'].toString(),
                    );
                  },
                ),
              ]),
          ShellRoute(
            builder: (context, state, child) => PriestShellRoute(child: child),
            routes: [
              // priest routes

              GoRoute(
                path: '/priest/${RouteNames.massRequests}',
                name: RouteNames.massRequests,
                builder: (context, state) => const BookedMassesPage(),
              ),
              GoRoute(
                path: '/create-event-page',
                name: RouteNames.createEvent,
                builder: (context, state) => const CreateEventPage(),
              ),

              GoRoute(
                path: '/priest/${RouteNames.createCommunityPage}',
                name: RouteNames.createCommunityPage,
                builder: (context, state) =>
                    const PrayerCommunityCreationPage(),
              ),
            ],
          ),
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
