import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/env/app_env.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/services/notifications_service.dart';
import 'package:jrnl_app/src/features/journal/data/mock_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/data/firestore_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/leaderboard/data/mock_leaderboard_repository.dart';
import 'package:jrnl_app/src/features/leaderboard/data/firestore_leaderboard_repository.dart';
import 'package:jrnl_app/src/features/prompts/data/mock_prompts_repository.dart';
import 'package:jrnl_app/src/features/users/data/mock_users_repository.dart';
import 'package:jrnl_app/src/features/users/data/firestore_users_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  test('profileRepositoryProvider returns in-memory implementation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(profileRepositoryProvider).getCurrentUserFirstName(),
      'Joshua',
    );
  });

  test('mock data env selects mock repos and noop notifications', () {
    final container = ProviderContainer(
      overrides: [
        appFlavorProvider.overrideWithValue(AppFlavor.dev),
        appEnvProvider.overrideWith(
          (ref) => const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Test',
            useMockData: true,
            useFirebaseEmulators: false,
            emulatorHost: 'localhost',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(notificationsServiceProvider), isA<NoopNotificationsService>());
    expect(container.read(usersRepositoryProvider), isA<MockUsersRepository>());
    expect(container.read(promptsRepositoryProvider), isA<MockPromptsRepository>());
    expect(
      container.read(journalEntriesRepositoryProvider),
      isA<MockJournalEntriesRepository>(),
    );
    expect(
      container.read(leaderboardRepositoryProvider),
      isA<MockLeaderboardRepository>(),
    );
  });

  test('live data env selects Firestore repos with injected clients', () {
    final firestore = FakeFirebaseFirestore();
    final auth = _MockFirebaseAuth();
    final container = ProviderContainer(
      overrides: [
        appFlavorProvider.overrideWithValue(AppFlavor.dev),
        appEnvProvider.overrideWith(
          (ref) => const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Test',
            useMockData: false,
            useFirebaseEmulators: false,
            emulatorHost: 'localhost',
          ),
        ),
        firebaseFirestoreProvider.overrideWithValue(firestore),
        firebaseAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(usersRepositoryProvider), isA<FirestoreUsersRepository>());
    expect(
      container.read(journalEntriesRepositoryProvider),
      isA<FirestoreJournalEntriesRepository>(),
    );
    expect(
      container.read(leaderboardRepositoryProvider),
      isA<FirestoreLeaderboardRepository>(),
    );
  });
}
