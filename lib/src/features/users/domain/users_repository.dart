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
}
