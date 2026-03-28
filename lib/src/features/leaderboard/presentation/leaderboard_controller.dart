import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../users/domain/app_user.dart';
import '../domain/leaderboard_cursor.dart';

class LeaderboardState {
  const LeaderboardState({
    required this.users,
    required this.nextCursor,
    required this.loadingMore,
  });

  final List<AppUser> users;
  final LeaderboardCursor? nextCursor;
  final bool loadingMore;

  bool get hasMore => nextCursor != null;
}

class LeaderboardController extends AutoDisposeAsyncNotifier<LeaderboardState> {
  static const int initialLimit = 50;
  static const int pageSize = 20;

  @override
  Future<LeaderboardState> build() async {
    final repo = ref.watch(leaderboardRepositoryProvider);
    final page = await repo.fetchPage(limit: initialLimit);
    // If we got fewer than initialLimit, treat as no more.
    final next = page.users.length < initialLimit ? null : page.nextCursor;
    return LeaderboardState(users: page.users, nextCursor: next, loadingMore: false);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final cursor = current.nextCursor;
    if (cursor == null || current.loadingMore) return;

    state = AsyncData(
      LeaderboardState(
        users: current.users,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );

    try {
      final repo = ref.read(leaderboardRepositoryProvider);
      final page = await repo.fetchPage(limit: pageSize, cursor: cursor);
      final combined = [...current.users, ...page.users];
      // If we got fewer than pageSize, stop.
      final next = page.users.length < pageSize ? null : page.nextCursor;
      state = AsyncData(
        LeaderboardState(users: combined, nextCursor: next, loadingMore: false),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final leaderboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<LeaderboardController, LeaderboardState>(
  LeaderboardController.new,
);
