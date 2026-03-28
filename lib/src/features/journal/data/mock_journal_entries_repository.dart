import 'dart:async';

import '../domain/journal_entries_repository.dart';
import '../domain/journal_entry.dart';

class MockJournalEntriesRepository implements JournalEntriesRepository {
  final _changes = StreamController<void>.broadcast();
  final Map<String, JournalEntry> _entries = {};
  int _id = 0;

  void dispose() => _changes.close();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  List<JournalEntry> _sorted() {
    final list = _entries.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<JournalEntry>> watchEntries() async* {
    yield _sorted();
    await for (final _ in _changes.stream) {
      yield _sorted();
    }
  }

  @override
  Stream<JournalEntry?> watchEntry(String entryId) async* {
    yield _entries[entryId];
    await for (final _ in _changes.stream) {
      yield _entries[entryId];
    }
  }

  @override
  Future<String> createEntry({
    required JournalEntryMode mode,
    required String promptText,
    required String bodyText,
  }) async {
    final now = DateTime.now();
    final id = 'mock_entry_${_id++}';
    _entries[id] = JournalEntry(
      id: id,
      uid: 'mock_uid',
      mode: mode,
      promptText: promptText,
      bodyText: bodyText,
      createdAt: now,
      updatedAt: now,
      energyIndex: null,
      moodIndex: null,
      internalIndex: null,
      status: EntryStatus.draft,
    );
    _notify();
    return id;
  }

  @override
  Future<void> updateEntryEvaluation({
    required String entryId,
    required int energyIndex,
    required int moodIndex,
    required int internalIndex,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = JournalEntry(
      id: existing.id,
      uid: existing.uid,
      mode: existing.mode,
      promptText: existing.promptText,
      bodyText: existing.bodyText,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      energyIndex: energyIndex,
      moodIndex: moodIndex,
      internalIndex: internalIndex,
      audioUrl: existing.audioUrl,
      transcript: existing.transcript,
      aiInsight: existing.aiInsight,
      status: existing.status,
    );
    _notify();
  }

  @override
  Future<void> updateEntryBody({
    required String entryId,
    required String bodyText,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = existing.copyWith(bodyText: bodyText);
    _notify();
  }

  @override
  Future<void> updateEntryAudio({
    required String entryId,
    required String audioUrl,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = existing.copyWith(
      audioUrl: audioUrl,
      status: EntryStatus.uploaded,
    );
    _notify();
  }

  @override
  Future<void> updateEntryTranscript({
    required String entryId,
    required String transcript,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = existing.copyWith(
      transcript: transcript,
      status: EntryStatus.transcribed,
    );
    _notify();
  }

  @override
  Future<void> saveInsight({
    required String entryId,
    required String insight,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = existing.copyWith(
      aiInsight: insight,
      status: EntryStatus.done,
    );
    _notify();
  }

  @override
  Future<void> updateEntryStatus({
    required String entryId,
    required EntryStatus status,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) return;
    _entries[entryId] = existing.copyWith(status: status);
    _notify();
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    _entries.remove(entryId);
    _notify();
  }

  @override
  Future<void> restoreEntry(JournalEntry entry) async {
    _entries[entry.id] = entry;
    _notify();
  }
}
