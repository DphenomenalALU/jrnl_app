import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/screens/leaderboard_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/features/leaderboard/domain/leaderboard_cursor.dart';
import 'package:jrnl_app/src/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';

import 'support/test_harness.dart';

class EmptyLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  }) async {
    return const LeaderboardPage(users: <AppUser>[], nextCursor: null);
  }
}

void main() {
  testWidgets('LeaderboardScreen: empty state', (tester) async {
    final prefs = await testPrefs();
    final overrides = baseOverrides(prefs: prefs)
      ..addAll([
        currentUidProvider.overrideWithValue(null),
        currentAppUserProvider.overrideWith((ref) => const Stream.empty()),
        leaderboardRepositoryProvider.overrideWithValue(
          EmptyLeaderboardRepository(),
        ),
      ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: Scaffold(body: LeaderboardScreen())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Social Leaderboard'), findsOneWidget);
    expect(find.textContaining('No contributors'), findsOneWidget);
  });
}
