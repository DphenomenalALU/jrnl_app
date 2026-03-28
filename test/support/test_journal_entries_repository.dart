import 'dart:async';

import 'package:jrnl_app/src/features/journal/domain/journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';

class TestJournalEntriesRepository implements JournalEntriesRepository {
  final _controller = StreamController<List<JournalEntry>>.broadcast();
  final Map<String, JournalEntry> _entries = {};

  int _id = 0;

  List<JournalEntry> get entries =>
      _entries.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void dispose() {
    _controller.close();
  }

  void _emit() => _controller.add(entries);

  @override
  Stream<List<JournalEntry>> watchEntries() {
    scheduleMicrotask(_emit);
    return _controller.stream;
  }

  @override
  Stream<JournalEntry?> watchEntry(String entryId) async* {
    yield _entries[entryId];
    await for (final _ in _controller.stream) {
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
    final id = 'e${_id++}';
    _entries[id] = JournalEntry(
      id: id,
      uid: 'testUid',
      mode: mode,
      promptText: promptText,
      bodyText: bodyText,
      createdAt: now,
      updatedAt: now,
      energyIndex: null,
      moodIndex: null,
      internalIndex: null,
    );
    _emit();
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
    if (existing == null) throw StateError('Entry not found: $entryId');
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
    );
    _emit();
  }

  @override
  Future<void> updateEntryBody({
    required String entryId,
    required String bodyText,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) throw StateError('Entry not found: $entryId');
    _entries[entryId] = JournalEntry(
      id: existing.id,
      uid: existing.uid,
      mode: existing.mode,
      promptText: existing.promptText,
      bodyText: bodyText,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      energyIndex: existing.energyIndex,
      moodIndex: existing.moodIndex,
      internalIndex: existing.internalIndex,
    );
    _emit();
  }

  @override
  Future<void> updateEntryAudio({
    required String entryId,
    required String audioUrl,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) throw StateError('Entry not found: $entryId');
    _entries[entryId] = existing.copyWith(
      audioUrl: audioUrl,
      status: EntryStatus.uploaded,
    );
    _emit();
  }

  @override
  Future<void> updateEntryTranscript({
    required String entryId,
    required String transcript,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) throw StateError('Entry not found: $entryId');
    _entries[entryId] = existing.copyWith(
      transcript: transcript,
      status: EntryStatus.transcribed,
    );
    _emit();
  }

  @override
  Future<void> saveInsight({
    required String entryId,
    required String insight,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) throw StateError('Entry not found: $entryId');
    _entries[entryId] = existing.copyWith(
      aiInsight: insight,
      status: EntryStatus.done,
    );
    _emit();
  }

  @override
  Future<void> updateEntryStatus({
    required String entryId,
    required EntryStatus status,
  }) async {
    final existing = _entries[entryId];
    if (existing == null) throw StateError('Entry not found: $entryId');
    _entries[entryId] = existing.copyWith(status: status);
    _emit();
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    _entries.remove(entryId);
    _emit();
  }

  @override
  Future<void> restoreEntry(JournalEntry entry) async {
    _entries[entry.id] = entry;
    _emit();
  }
}
