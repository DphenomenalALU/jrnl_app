import 'package:cloud_firestore/cloud_firestore.dart';

import '../../users/domain/app_user.dart';
import '../domain/leaderboard_cursor.dart';
import '../domain/leaderboard_repository.dart';

class FirestoreLeaderboardRepository implements LeaderboardRepository {
  FirestoreLeaderboardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Query<Map<String, dynamic>> _baseQuery(int limit) {
    return _users
        .orderBy('xpTotal', descending: true)
        .orderBy(FieldPath.documentId)
        .limit(limit);
  }

  @override
  Future<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardCursor? cursor,
  }) async {
    var q = _baseQuery(limit);
    if (cursor != null) {
      q = q.startAfter([cursor.lastXpTotal, cursor.lastUid]);
    }

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
      next = LeaderboardCursor(lastXpTotal: lastXp, lastUid: last.id);
    }

    return LeaderboardPage(users: users, nextCursor: next);
  }
}

