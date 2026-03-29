import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/screens/ai_insights_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/features/journal/data/mock_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';
import 'package:jrnl_app/src/features/journal/presentation/insights_provider.dart';

import 'support/test_harness.dart';

void main() {
  testWidgets('AiInsightsScreen: save insight shows snackbar', (tester) async {
    final prefs = await testPrefs();
    final user = testUser(uid: 'u1');
    final overrides = baseOverrides(prefs: prefs, user: user);

    final repo = MockJournalEntriesRepository();
    addTearDown(repo.dispose);

    const entryId = 'e1';
    final entry = JournalEntry(
      id: entryId,
      uid: user.uid,
      mode: JournalEntryMode.text,
      promptText: 'Prompt',
      bodyText: 'Body',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      energyIndex: 1,
      moodIndex: 1,
      internalIndex: 1,
      transcript: 'Transcript',
      aiInsight: 'Insight text',
      status: EntryStatus.transcribed,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          journalEntriesRepositoryProvider.overrideWithValue(repo),
          insightsEntryProvider.overrideWith((ref, id) => Stream.value(entry)),
        ],
        child: const MaterialApp(home: AiInsightsScreen(entryId: entryId)),
      ),
    );
    await tester.pump();

    expect(find.textContaining('AI INSIGHTS'), findsWidgets);
    await tester.ensureVisible(find.text('SAVE TO INSIGHTS'));
    await tester.tap(find.text('SAVE TO INSIGHTS'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntilFound(tester, find.text('Insight saved.'));
  });
}
