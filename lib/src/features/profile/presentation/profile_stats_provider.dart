import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/profile_stats.dart';

final profileStatsProvider = StreamProvider.autoDispose<ProfileStats>((ref) {
  return ref.watch(profileStatsServiceProvider).watchStats();
});
