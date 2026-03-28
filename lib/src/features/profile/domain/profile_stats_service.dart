import 'profile_stats.dart';

abstract interface class ProfileStatsService {
  Stream<ProfileStats> watchStats();
}

