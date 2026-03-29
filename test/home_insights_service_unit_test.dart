import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/src/features/home/data/real_home_insights_service.dart';
import 'package:jrnl_app/src/features/journal/data/mock_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';

void main() {
  group('RealHomeInsightsService', () {
    test('baseline is null until at least 3 evaluated entries', () async {
      final repo = MockJournalEntriesRepository();
      addTearDown(repo.dispose);
      final svc = RealHomeInsightsService(repo);

      await repo.restoreEntry(
        JournalEntry(
          id: 'e1',
          uid: 'u',
          mode: JournalEntryMode.text,
          promptText: 'P',
          bodyText: 'B',
          createdAt: DateTime(2026, 1, 1, 9),
          updatedAt: DateTime(2026, 1, 1, 9),
          energyIndex: 2,
          moodIndex: 2,
          internalIndex: 2,
        ),
      );
      await repo.restoreEntry(
        JournalEntry(
          id: 'e2',
          uid: 'u',
          mode: JournalEntryMode.text,
          promptText: 'P',
          bodyText: 'B',
          createdAt: DateTime(2026, 1, 2, 9),
          updatedAt: DateTime(2026, 1, 2, 9),
          energyIndex: 2,
          moodIndex: 2,
          internalIndex: 2,
        ),
      );

      final v = await svc.watchInsights().first;
      expect(v.baseline, isNull);
      expect(v.observationBody, isNotEmpty);
    });

    test('baseline + observation compute from evaluated entries', () async {
      final repo = MockJournalEntriesRepository();
      addTearDown(repo.dispose);
      final svc = RealHomeInsightsService(repo);

      final now = DateTime(2026, 1, 10, 8);
      Future<void> add({
        required String id,
        required int hour,
        int? energy,
        int? mood,
        int? internal,
      }) async {
        await repo.restoreEntry(
          JournalEntry(
            id: id,
            uid: 'u',
            mode: JournalEntryMode.text,
            promptText: 'P',
            bodyText: 'B',
            createdAt: DateTime(now.year, now.month, now.day, hour),
            updatedAt: DateTime(now.year, now.month, now.day, hour),
            energyIndex: energy,
            moodIndex: mood,
            internalIndex: internal,
          ),
        );
      }

      // 3 evaluated entries in the morning bucket -> baseline should appear and
      // observation should mention mornings.
      await add(id: 'e1', hour: 8, energy: 2, mood: 2, internal: 2);
      await add(id: 'e2', hour: 9, energy: 2, mood: 3, internal: 2);
      await add(id: 'e3', hour: 10, energy: 3, mood: 2, internal: 3);

      final v = await svc.watchInsights().first;
      expect(v.baseline, isNotNull);
      expect(v.baseline!.sampleSize, greaterThanOrEqualTo(3));
      expect(v.observationBody.toLowerCase(), contains('morning'));
    });
  });
}
