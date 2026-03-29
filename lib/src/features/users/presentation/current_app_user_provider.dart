import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/app_user.dart';

final currentUidProvider = Provider<String?>((ref) {
  // Listen to the reactive auth stream so consumers rebuild when auth
  // state is restored/changes, but also fall back to `currentUser` for
  // synchronous access when it's already available.
  final auth = ref.watch(firebaseAuthProvider);
  final streamUser = ref.watch(firebaseUserChangesProvider).valueOrNull;
  return streamUser?.uid ?? auth.currentUser?.uid;
});

final currentAppUserProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(usersRepositoryProvider).watchUser(uid);
});
