import 'dart:async';

import '../domain/app_user.dart';
import '../domain/users_repository.dart';

class MockUsersRepository implements UsersRepository {
  final _changes = StreamController<void>.broadcast();
  final Map<String, AppUser> _users = {};

  MockUsersRepository() {
    final uid = 'mock_uid';
    _users[uid] = AppUser(
      uid: uid,
      displayName: 'Mock User',
      photoUrl: null,
      bio: 'This is mock profile text.',
      location: 'Mock City',
      xpTotal: 2450,
      streakCount: 14,
      tier: 'Tier XII',
      createdAt: DateTime.now(),
    );
  }

  void dispose() => _changes.close();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Stream<AppUser?> watchUser(String uid) async* {
    yield _users[uid];
    await for (final _ in _changes.stream) {
      yield _users[uid];
    }
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    return _users[uid];
  }

  @override
  Future<void> upsertUser(AppUser user) async {
    _users[user.uid] = user;
    _notify();
  }

  @override
  Future<void> upsertUserProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final existing = _users[uid];
    final next = (existing == null)
        ? AppUser(
            uid: uid,
            displayName: displayName,
            photoUrl: photoUrl,
            bio: null,
            location: null,
            xpTotal: 0,
            streakCount: 0,
            tier: null,
            createdAt: DateTime.now(),
          )
        : existing.copyWith(
            displayName: displayName,
            photoUrl: photoUrl ?? existing.photoUrl,
          );
    _users[uid] = next;
    _notify();
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
    String? bio,
    String? location,
    String? email,
  }) async {
    final existing = _users[uid];
    if (existing == null) {
      _users[uid] = AppUser(
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
        bio: bio,
        location: location,
        xpTotal: 0,
        streakCount: 0,
        tier: null,
        createdAt: DateTime.now(),
      );
    } else {
      _users[uid] = existing.copyWith(
        displayName: displayName,
        photoUrl: photoUrl ?? existing.photoUrl,
        bio: bio ?? existing.bio,
        location: location ?? existing.location,
      );
    }
    _notify();
  }

  @override
  Stream<List<AppUser>> watchLeaderboard({int limit = 20}) async* {
    List<AppUser> current() {
      final list = _users.values.toList()
        ..sort((a, b) => b.xpTotal.compareTo(a.xpTotal));
      return list.take(limit).toList();
    }

    yield current();
    await for (final _ in _changes.stream) {
      yield current();
    }
  }
}

