import 'package:cloud_firestore/cloud_firestore.dart';

import '../../users/domain/app_user.dart';
import '../domain/leaderboard_cursor.dart';
import '../domain/leaderboard_repository.dart';

class FirestoreLeaderboardRepository implements LeaderboardRepository {
  FirestoreLeaderboardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Tie-break on stored [UsersRepository] `uid` (must match document id) so
  /// pagination works with `fake_cloud_firestore` and real Firestore indexes.
  Query<Map<String, dynamic>> _orderedUsers() {
    return _users.orderBy('xpTotal', descending: true).orderBy('uid');
  }

  @override
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  }) async {
    // Firestore: cursor before limit (limit → startAfter would page only the first slice).
    var q = _orderedUsers();
    if (cursor != null) {
      q = q.startAfter([cursor.lastXpTotal, cursor.lastUid]);
    }
    q = q.limit(limit);

    final snap = await q.get();
    final users = snap.docs
        .map(
          (d) => AppUser.fromJson(<String, dynamic>{
            ...d.data(),
            'uid': d.id,
          }),
        )
        .toList();

    LeaderboardCursor? next;
    if (snap.docs.isNotEmpty) {
      final last = snap.docs.last;
      final lastXp = (last.data()['xpTotal'] as num?)?.toInt() ?? 0;
      next = LeaderboardCursor(
        lastXpTotal: lastXp,
        lastUid: (last.data()['uid'] as String?) ?? last.id,
      );
    }

    return LeaderboardPage(users: users, nextCursor: next);
  }
}

