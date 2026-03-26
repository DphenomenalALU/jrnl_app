import 'journal_entry.dart';

abstract interface class JournalEntriesRepository {
  Stream<List<JournalEntry>> watchEntries();

  Stream<JournalEntry?> watchEntry(String entryId);

  Future<String> createEntry({
    required JournalEntryMode mode,
    required String promptText,
    required String bodyText,
  });

  Future<void> updateEntryEvaluation({
    required String entryId,
    required int energyIndex,
    required int moodIndex,
    required int internalIndex,
  });

  Future<void> updateEntryBody({
    required String entryId,
    required String bodyText,
  });

  Future<void> deleteEntry(String entryId);

  Future<void> restoreEntry(JournalEntry entry);
}

