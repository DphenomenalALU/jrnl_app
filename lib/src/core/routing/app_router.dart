import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../screens/home_screen.dart';
import '../../../screens/journal_screen.dart';
import '../../../screens/leaderboard_screen.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/user_profile_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
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
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final signedIn = isSignedIn();
      final inAuth = state.uri.path.startsWith('/auth');

      if (!signedIn && !inAuth) {
        return '/auth/sign-in';
      }
      if (signedIn && inAuth) {
        return '/home';
      }
      return null;
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
