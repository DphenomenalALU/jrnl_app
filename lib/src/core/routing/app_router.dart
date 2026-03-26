import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../screens/home_screen.dart';
import '../../../screens/journal_screen.dart';
import '../../../screens/leaderboard_screen.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/user_profile_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/journal/presentation/journal_entry_screen.dart';
import '../../features/journal/presentation/journal_history_screen.dart';
import '../presentation/theme/app_colors.dart';
import '../presentation/widgets/jrnl_bottom_nav.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _journalNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'journal');
final GlobalKey<NavigatorState> _leaderboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'leaderboard');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

GoRouter createAppRouter({
  required Listenable refreshListenable,
  required bool Function() isSignedIn,
  required bool Function() isEmailVerified,
}) {
  var debugLogs = false;
  assert(() {
    debugLogs = true;
    return true;
  }());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // Start on auth route; redirect will take signed-in users to /home.
    initialLocation: '/auth/sign-in',
    refreshListenable: refreshListenable,
    debugLogDiagnostics: debugLogs,
    redirect: (context, state) {
      final signedIn = isSignedIn();
      final verified = isEmailVerified();
      final inAuth = state.uri.path.startsWith('/auth');
      final inVerify = state.uri.path == '/auth/verify-email';

      if (!signedIn && !inAuth) {
        return '/auth/sign-in';
      }
      if (signedIn && !verified && !inVerify) {
        return '/auth/verify-email';
      }
      if (signedIn && verified && inAuth) {
        return '/home';
      }
      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Routing error:\n${state.error}\n\nLocation: ${state.uri}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/auth',
        redirect: (_, _) => '/auth/sign-in',
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/reset-password',
        name: 'resetPassword',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ResetPasswordScreen(initialEmail: email);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/verify-email',
        name: 'verifyEmail',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _JrnlTabShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) {
                  return NoTransitionPage<void>(
                    child: HomeScreen(
                      onStartJournaling: () {
                        final session =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        context.go('/journal?session=$session');
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _journalNavigatorKey,
            routes: [
              GoRoute(
                path: '/journal',
                name: 'journal',
                pageBuilder: (context, state) {
                  final session = state.uri.queryParameters['session'];
                  return NoTransitionPage<void>(
                    child: JournalScreen(
                      key: session == null ? null : ValueKey<String>(session),
                      onPostEntryComplete: () => context.go('/leaderboard'),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'history',
                    name: 'journalHistory',
                    builder: (context, state) => const JournalHistoryScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'entry/:id',
                    name: 'journalEntry',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JournalEntryScreen(entryId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _leaderboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/leaderboard',
                name: 'leaderboard',
                pageBuilder: (context, state) {
                  return const NoTransitionPage<void>(
                    child: LeaderboardScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) {
                  return const NoTransitionPage<void>(
                    child: ProfileScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/user/:mode',
        name: 'userProfile',
        builder: (context, state) {
          final modeParam = state.pathParameters['mode'];
          final mode = modeParam == 'other'
              ? UserProfileMode.other
              : UserProfileMode.me;
          return UserProfileScreen(mode: mode);
        },
      ),
    ],
  );
}

class _JrnlTabShell extends StatelessWidget {
  const _JrnlTabShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: JrnlBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(i),
      ),
    );
  }
}
