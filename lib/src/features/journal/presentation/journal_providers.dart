import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/journal_entry.dart';

final journalEntriesProvider = StreamProvider.autoDispose<List<JournalEntry>>(
  (ref) => ref.watch(journalEntriesRepositoryProvider).watchEntries(),
);

final journalEntryProvider =
    StreamProvider.autoDispose.family<JournalEntry?, String>(
  (ref, entryId) => ref.watch(journalEntriesRepositoryProvider).watchEntry(entryId),
);

