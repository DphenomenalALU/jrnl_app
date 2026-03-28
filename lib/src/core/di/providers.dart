import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_env.dart';
import '../env/app_flavor.dart';
import '../../features/journal/data/firestore_journal_entries_repository.dart';
import '../../features/journal/data/mock_journal_entries_repository.dart';
import '../../features/journal/domain/journal_entries_repository.dart';
import '../../features/home/data/mock_home_insights_service.dart';
import '../../features/home/data/real_home_insights_service.dart';
import '../../features/home/domain/home_insights_service.dart';
import '../../features/leaderboard/data/firestore_leaderboard_repository.dart';
import '../../features/leaderboard/data/mock_leaderboard_repository.dart';
import '../../features/leaderboard/domain/leaderboard_repository.dart';
import '../../features/prompts/data/firestore_prompts_repository.dart';
import '../../features/prompts/data/mock_prompts_repository.dart';
import '../../features/prompts/domain/prompts_repository.dart';
import '../../features/profile/data/mock_profile_stats_service.dart';
import '../../features/profile/data/real_profile_stats_service.dart';
import '../../features/profile/domain/profile_stats_service.dart';
import '../routing/app_router.dart';
import '../routing/router_refresh_notifier.dart';
import '../../features/users/data/firestore_users_repository.dart';
import '../../features/users/data/mock_users_repository.dart';
import '../../features/users/domain/app_user.dart';
import '../../features/users/domain/users_repository.dart';

final appFlavorProvider = Provider<AppFlavor>((ref) {
  throw UnimplementedError('appFlavorProvider must be overridden in bootstrap.');
});

final appEnvProvider = Provider<AppEnv>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  return appEnvForFlavor(flavor);
});

final useMockDataProvider = Provider<bool>((ref) {
  return ref.watch(appEnvProvider).useMockData;
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

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  if (ref.watch(useMockDataProvider)) {
    final repo = MockUsersRepository();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return FirestoreUsersRepository(ref.watch(firebaseFirestoreProvider));
});

final promptsRepositoryProvider = Provider<PromptsRepository>((ref) {
  if (ref.watch(useMockDataProvider)) {
    return const MockPromptsRepository();
  }
  return FirestorePromptsRepository(ref.watch(firebaseFirestoreProvider));
});

final journalEntriesRepositoryProvider = Provider<JournalEntriesRepository>(
  (ref) {
    if (ref.watch(useMockDataProvider)) {
      final repo = MockJournalEntriesRepository();
      ref.onDispose(repo.dispose);
      return repo;
    }
    return FirestoreJournalEntriesRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(firebaseAuthProvider),
    );
  },
);

final homeInsightsServiceProvider = Provider<HomeInsightsService>((ref) {
  if (ref.watch(useMockDataProvider)) {
    return const MockHomeInsightsService();
  }
  return RealHomeInsightsService(ref.watch(journalEntriesRepositoryProvider));
});

final profileStatsServiceProvider = Provider<ProfileStatsService>((ref) {
  if (ref.watch(useMockDataProvider)) {
    return const MockProfileStatsService();
  }
  return RealProfileStatsService(ref, ref.watch(usersRepositoryProvider));
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  if (ref.watch(useMockDataProvider)) {
    return MockLeaderboardRepository();
  }
  return FirestoreLeaderboardRepository(ref.watch(firebaseFirestoreProvider));
});

final leaderboardProvider = StreamProvider.autoDispose.family<List<AppUser>, int>(
  (ref, limit) {
    return ref.watch(usersRepositoryProvider).watchLeaderboard(limit: limit);
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
