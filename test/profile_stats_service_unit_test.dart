import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/features/profile/data/real_profile_stats_service.dart';
import 'package:jrnl_app/src/features/profile/domain/profile_stats_service.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';
import 'package:jrnl_app/src/features/users/data/mock_users_repository.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';

void main() {
  group('RealProfileStatsService', () {
    test('signed out -> empty stats', () async {
      final usersRepo = MockUsersRepository();
      addTearDown(usersRepo.dispose);

      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWithValue(null),
          usersRepositoryProvider.overrideWithValue(usersRepo),
        ],
      );
      addTearDown(container.dispose);

      final serviceProvider = Provider<ProfileStatsService>((ref) {
        return RealProfileStatsService(ref, ref.watch(usersRepositoryProvider));
      });
      final stats = await container.read(serviceProvider).watchStats().first;
      expect(stats.xpTotal, 0);
      expect(stats.tierLabel, '—');
    });

    test('computes tier + roman + remaining xp', () async {
      final usersRepo = MockUsersRepository();
      addTearDown(usersRepo.dispose);

      const uid = 'u1';
      await usersRepo.upsertUser(
        AppUser(
          uid: uid,
          displayName: 'User',
          photoUrl: null,
          bio: null,
          location: null,
          xpTotal: 1500,
          streakCount: 3,
          tier: null,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWithValue(uid),
          usersRepositoryProvider.overrideWithValue(usersRepo),
        ],
      );
      addTearDown(container.dispose);

      final serviceProvider = Provider<ProfileStatsService>((ref) {
        return RealProfileStatsService(ref, ref.watch(usersRepositoryProvider));
      });
      final stats = await container.read(serviceProvider).watchStats().first;
      expect(stats.xpTotal, 1500);
      expect(stats.tierLabel, contains('Tier'));
      expect(stats.nextTierLabel, contains('Tier'));
      expect(stats.progressToNextTier, closeTo(0.5, 0.001));
      expect(stats.xpRemainingToNextTier, 500);
    });

    test('parses numeric tier and roman tier tokens', () async {
      final usersRepo = MockUsersRepository();
      addTearDown(usersRepo.dispose);

      const uid = 'u2';
      await usersRepo.upsertUser(
        AppUser(
          uid: uid,
          displayName: 'User',
          photoUrl: null,
          bio: null,
          location: null,
          xpTotal: 999,
          streakCount: 1,
          tier: 'Tier XII',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWithValue(uid),
          usersRepositoryProvider.overrideWithValue(usersRepo),
        ],
      );
      addTearDown(container.dispose);

      final serviceProvider = Provider<ProfileStatsService>((ref) {
        return RealProfileStatsService(ref, ref.watch(usersRepositoryProvider));
      });
      final stats = await container.read(serviceProvider).watchStats().first;
      expect(stats.tierLabel, 'Tier XII');
      expect(stats.nextTierLabel, isNotEmpty);
    });
  });
}
