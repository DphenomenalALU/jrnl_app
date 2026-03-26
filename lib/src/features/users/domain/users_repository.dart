import '../domain/app_user.dart';

abstract interface class UsersRepository {
  Stream<AppUser?> watchUser(String uid);
  Future<AppUser?> getUser(String uid);
  Future<void> upsertUser(AppUser user);
}

