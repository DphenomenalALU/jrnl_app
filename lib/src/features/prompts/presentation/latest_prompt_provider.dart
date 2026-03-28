import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/prompt.dart';

final latestPromptProvider = StreamProvider.autoDispose<Prompt?>((ref) {
  return ref.watch(promptsRepositoryProvider).watchLatestActive();
});
