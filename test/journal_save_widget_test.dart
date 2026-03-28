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

import 'fakes/fake_journal_entries_repository.dart';

void main() {
  testWidgets('Journal DONE creates entry and opens Entry Summary', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeJournalEntriesRepository();
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
        child: const MaterialApp(home: JournalScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Enter some text.
    await tester.enterText(find.byType(TextField), 'Hello from widget test');

    // Tap DONE.
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    // Entry saved + navigated to Entry Summary screen.
    expect(fakeRepo.entries, hasLength(1));
    expect(find.text('Entry Summary'), findsOneWidget);
  });
}
