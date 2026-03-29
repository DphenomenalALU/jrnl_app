import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/features/leaderboard/domain/leaderboard_cursor.dart';
import 'package:jrnl_app/src/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:jrnl_app/src/features/leaderboard/presentation/leaderboard_controller.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';

class _FixedLeaderboardRepo implements LeaderboardRepository {
  _FixedLeaderboardRepo(this.pages);

  final List<List<AppUser>> pages;
  var calls = 0;

  @override
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  }) async {
    final idx = calls.clamp(0, pages.length - 1);
    final users = pages[idx];
    calls += 1;
    final next = users.isEmpty
        ? null
        : LeaderboardCursor(
            lastXpTotal: users.last.xpTotal,
            lastUid: users.last.uid,
          );
    return LeaderboardPage(users: users, nextCursor: next);
  }
}

AppUser _u(String uid, int xp) => AppUser(
  uid: uid,
  displayName: uid,
  xpTotal: xp,
  streakCount: 0,
  tier: null,
  photoUrl: null,
  bio: null,
  location: null,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  test('LeaderboardController: build + loadMore aggregates pages', () async {
    final repo = _FixedLeaderboardRepo([
      List.generate(
        LeaderboardController.initialLimit,
        (i) => _u('u$i', 1000 - i),
      ),
      List.generate(3, (i) => _u('m$i', 80 - i)),
    ]);

    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue('testUid'),
        leaderboardRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(leaderboardControllerProvider.future);
    expect(state.users, hasLength(LeaderboardController.initialLimit));
    expect(state.hasMore, isTrue);

    await container.read(leaderboardControllerProvider.notifier).loadMore();
    final after = container.read(leaderboardControllerProvider).value!;
    expect(after.users, hasLength(LeaderboardController.initialLimit + 3));
  });

  test('LeaderboardController: loadMore no-ops without cursor', () async {
    final repo = _FixedLeaderboardRepo([const <AppUser>[]]);

    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue('testUid'),
        leaderboardRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(leaderboardControllerProvider.future);
    expect(state.users, isEmpty);
    expect(state.hasMore, isFalse);

    await container.read(leaderboardControllerProvider.notifier).loadMore();
    expect(repo.calls, 1);
  });
}
