import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../users/presentation/current_app_user_provider.dart';
import '../domain/fallback_journal_prompts.dart';
import 'latest_prompt_provider.dart';

/// One random fallback per [uid]; disposed when uid changes so each login can get a new pick.
final _sessionJournalPromptFamily = Provider.autoDispose.family<String, String>((
  ref,
  uid,
) {
  final list = kFallbackJournalPrompts;
  return list[Random().nextInt(list.length)];
});

/// Prompt shown on Home / Journal: Firestore latest active when present; otherwise session
/// random pool (real) or [kDemoJournalPromptDefault] (mock).
final effectiveJournalPromptProvider = Provider.autoDispose<String>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  final async = ref.watch(latestPromptProvider);
  final prompt = async.valueOrNull;
  final text = prompt?.text.trim() ?? '';
  if (text.isNotEmpty) return text;

  if (useMock) return kDemoJournalPromptDefault;

  final uid = ref.watch(currentUidProvider);
  if (uid == null || uid.isEmpty) {
    return kFallbackJournalPrompts.first;
  }
  return ref.watch(_sessionJournalPromptFamily(uid));
});
