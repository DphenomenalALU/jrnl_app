import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/home_insights.dart';

final homeInsightsProvider = StreamProvider.autoDispose<HomeInsights>((ref) {
  return ref.watch(homeInsightsServiceProvider).watchInsights();
});
