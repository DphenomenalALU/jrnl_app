import '../../users/domain/app_user.dart';
import 'leaderboard_cursor.dart';

class LeaderboardPage {
  const LeaderboardPage({
    required this.users,
    required this.nextCursor,
  });

  final List<AppUser> users;
  final LeaderboardCursor? nextCursor;
}

abstract interface class LeaderboardRepository {
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  });
}

