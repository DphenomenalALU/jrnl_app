import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_env.dart';
import '../env/app_flavor.dart';
import '../../features/journal/data/firestore_journal_entries_repository.dart';
import '../../features/journal/domain/journal_entries_repository.dart';
import '../../features/prompts/data/firestore_prompts_repository.dart';
import '../../features/prompts/domain/prompts_repository.dart';
import '../routing/app_router.dart';
import '../routing/router_refresh_notifier.dart';
import '../../features/users/data/firestore_users_repository.dart';
import '../../features/users/domain/users_repository.dart';

final appFlavorProvider = Provider<AppFlavor>((ref) {
  throw UnimplementedError('appFlavorProvider must be overridden in bootstrap.');
});

final appEnvProvider = Provider<AppEnv>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  return appEnvForFlavor(flavor);
});

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = RouterRefreshNotifier(auth.userChanges());
  final router = createAppRouter(
    refreshListenable: refresh,
    isSignedIn: () => auth.currentUser != null,
    isEmailVerified: () => auth.currentUser?.emailVerified ?? false,
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refresh.dispose);
  return router;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return FirestoreUsersRepository(ref.watch(firebaseFirestoreProvider));
});

final promptsRepositoryProvider = Provider<PromptsRepository>((ref) {
  return FirestorePromptsRepository(ref.watch(firebaseFirestoreProvider));
});

final journalEntriesRepositoryProvider = Provider<JournalEntriesRepository>(
  (ref) {
    return FirestoreJournalEntriesRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(firebaseAuthProvider),
    );
  },
);

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final firebaseUserChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges();
});

abstract interface class ProfileRepository {
  String getCurrentUserFirstName();
}

class InMemoryProfileRepository implements ProfileRepository {
  const InMemoryProfileRepository();

  @override
  String getCurrentUserFirstName() => 'Joshua';
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const InMemoryProfileRepository();
});
