import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/screens/journal_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entries_repository.dart';
import 'package:jrnl_app/src/features/prompts/domain/prompt.dart';
import 'package:jrnl_app/src/features/prompts/presentation/latest_prompt_provider.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';

import 'support/test_journal_entries_repository.dart';

void main() {
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for widget: $finder');
  }

  testWidgets('Journal DONE creates entry and opens Entry Summary', (
    WidgetTester tester,
  ) async {
    final fakeRepo = TestJournalEntriesRepository();
    addTearDown(fakeRepo.dispose);

    final prompt = Prompt(
      id: 'p1',
      text: 'Test prompt?',
      date: DateTime(2026, 1, 1),
      active: true,
    );

    final user = AppUser(
      uid: 'testUid',
      displayName: 'Test User',
      xpTotal: 0,
      streakCount: 7,
      tier: null,
      photoUrl: null,
      bio: null,
      location: null,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalEntriesRepositoryProvider.overrideWithValue(
            fakeRepo as JournalEntriesRepository,
          ),
          currentUidProvider.overrideWithValue('testUid'),
          currentAppUserProvider.overrideWith((ref) => Stream.value(user)),
          latestPromptProvider.overrideWith((ref) => Stream.value(prompt)),
        ],
        // In the real app JournalScreen is hosted under a Material/Scaffold
        // (via the shell route). Wrap it here to avoid "No Material widget found"
        // during widget tests.
        child: const MaterialApp(home: Scaffold(body: JournalScreen())),
      ),
    );

    // Avoid pumpAndSettle here because TextField cursor blinking can keep the
    // tree "dirty" indefinitely. A few pumps are sufficient for initial streams.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Enter some text.
    await tester.enterText(find.byType(TextField), 'Hello from widget test');

    // Tap DONE.
    await tester.tap(find.text('DONE'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Entry Summary'));

    // Entry saved + navigated to Entry Summary screen.
    expect(fakeRepo.entries, hasLength(1));
    expect(find.text('Entry Summary'), findsOneWidget);
  });
}
