import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/app_user.dart';

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseAuthProvider).currentUser?.uid;
});

final currentAppUserProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(usersRepositoryProvider).watchUser(uid);
});

