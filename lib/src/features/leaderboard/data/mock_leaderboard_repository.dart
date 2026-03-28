import '../../users/domain/app_user.dart';
import '../domain/leaderboard_cursor.dart';
import '../domain/leaderboard_repository.dart';

class MockLeaderboardRepository implements LeaderboardRepository {
  MockLeaderboardRepository({this.totalUsers = 80});

  final int totalUsers;

  List<AppUser> get _all {
    final list = <AppUser>[];
    for (var i = 0; i < totalUsers; i++) {
      final rank = i + 1;
      final xp = 3000 - i * 25;
      list.add(
        AppUser(
          uid: 'mock_user_$rank',
          displayName: 'Mock User ${rank.toString().padLeft(2, '0')}',
          photoUrl: null,
          bio: null,
          location: null,
          xpTotal: xp,
          streakCount: (rank % 17) + 1,
          tier: 'Tier ${(rank % 15) + 1}',
          createdAt: DateTime.now(),
        ),
      );
    }
    return list;
  }

  @override
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  }) async {
    final all = _all;
    var startIndex = 0;
    if (cursor != null) {
      final idx = all.indexWhere(
        (u) => u.uid == cursor.lastUid && u.xpTotal == cursor.lastXpTotal,
      );
      startIndex = idx < 0 ? 0 : idx + 1;
    }
    final users = all.skip(startIndex).take(limit).toList();
    final next = users.isEmpty
        ? null
        : LeaderboardCursor(
            lastXpTotal: users.last.xpTotal,
            lastUid: users.last.uid,
          );
    return LeaderboardPage(users: users, nextCursor: next);
  }
}

