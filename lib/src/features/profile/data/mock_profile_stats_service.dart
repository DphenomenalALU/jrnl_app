import '../domain/profile_stats.dart';
import '../domain/profile_stats_service.dart';

class MockProfileStatsService implements ProfileStatsService {
  const MockProfileStatsService();

  @override
  Stream<ProfileStats> watchStats() {
    return Stream.value(
      const ProfileStats(
        tierLabel: 'Tier XII',
        xpTotal: 2450,
        progressToNextTier: 0.78,
        xpRemainingToNextTier: 530,
        nextTierLabel: 'Tier XIII',
      ),
    );
  }
}

