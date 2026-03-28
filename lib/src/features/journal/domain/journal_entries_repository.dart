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

  /// Sets the audio download URL and transitions the entry to [EntryStatus.uploaded].
  Future<void> updateEntryAudio({
    required String entryId,
    required String audioUrl,
  });

  /// Sets the transcript and transitions the entry to [EntryStatus.transcribed].
  Future<void> updateEntryTranscript({
    required String entryId,
    required String transcript,
  });

  /// Persists an AI insight string and marks the entry as [EntryStatus.done].
  Future<void> saveInsight({required String entryId, required String insight});

  /// Updates only the processing status field.
  Future<void> updateEntryStatus({
    required String entryId,
    required EntryStatus status,
  });

  Future<void> deleteEntry(String entryId);

  Future<void> restoreEntry(JournalEntry entry);
}
