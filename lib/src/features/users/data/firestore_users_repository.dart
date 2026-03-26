import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';
import '../domain/users_repository.dart';

class FirestoreUsersRepository implements UsersRepository {
  FirestoreUsersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromJson(<String, dynamic>{...data, 'uid': uid});
    });
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return AppUser.fromJson(<String, dynamic>{...data, 'uid': uid});
  }

  @override
  Future<void> upsertUser(AppUser user) async {
    await _users.doc(user.uid).set(
          user.toJson()..remove('uid'),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> upsertUserProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final doc = _users.doc(uid);
    final snap = await doc.get();

    final data = <String, Object?>{
      'displayName': displayName,
      ...?photoUrl == null ? null : <String, Object?>{'photoUrl': photoUrl},
    };

    if (!snap.exists) {
      data['xpTotal'] = 0;
      data['streakCount'] = 0;
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await doc.set(data, SetOptions(merge: true));
  }
}
