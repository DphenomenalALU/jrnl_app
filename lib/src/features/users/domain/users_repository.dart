import '../domain/app_user.dart';

abstract interface class UsersRepository {
  Stream<AppUser?> watchUser(String uid);
  Future<AppUser?> getUser(String uid);
  Future<void> upsertUser(AppUser user);

  /// Ensures the user doc exists and is updated with profile fields without
  /// overwriting progression fields like `xpTotal`/`streakCount` once created.
  Future<void> upsertUserProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
  });

  /// Updates editable profile fields (displayName, photoUrl, bio, location).
  /// Also persists [email] to `users/{uid}/private/info` if provided.
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
    String? bio,
    String? location,
    String? email,
  });

  /// Returns the top [limit] users ordered by xpTotal descending.
  Stream<List<AppUser>> watchLeaderboard({int limit = 20});
}
