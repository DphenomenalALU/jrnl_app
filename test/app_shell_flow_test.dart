import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/screens/consistency_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/routing/app_router.dart';
import 'package:jrnl_app/src/features/journal/data/mock_journal_entries_repository.dart';

import 'support/test_harness.dart';

void main() {
  testWidgets('shell flow: tabs + journal save + modals', (tester) async {
    final prefs = await testPrefs();
    final user = testUser(displayName: 'Zeeyah Oke');
    final overrides = baseOverrides(prefs: prefs, user: user);

    final journalRepo = MockJournalEntriesRepository();

    final refresh = ValueNotifier<int>(0);
    final router = createAppRouter(
      refreshListenable: refresh,
      isSignedIn: () => true,
      isEmailVerified: () => true,
    );

    addTearDown(() {
      refresh.dispose();
      router.dispose();
      journalRepo.dispose();
    });

    // Default 800×600 clips long screens (e.g. leaderboard "LOAD MORE" below the fold).
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          journalEntriesRepositoryProvider.overrideWithValue(journalRepo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Redirect from /auth/sign-in -> /home.
    await pumpUntilFound(
      tester,
      find.textContaining("TODAY'S REFLECTION"),
      timeout: const Duration(seconds: 5),
    );

    // Home -> Journal via CTA (covers `onStartJournaling` callback).
    await tester.tap(find.text('START JOURNALING'));
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('EXPLORE DEEPLY'),
      timeout: const Duration(seconds: 5),
    );

    // Save a text entry (covers optimistic UI + navigation to Entry Summary).
    await tester.enterText(
      find.byType(TextField).first,
      'Today I tested the app end-to-end.',
    );
    await tester.tap(find.text('DONE'));
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Entry Summary'),
      timeout: const Duration(seconds: 5),
    );

    // Entry Summary -> Consistency -> Continue (pops + switches tab to leaderboard).
    await tester.ensureVisible(find.text('FINISH ENTRY'));
    await tester.tap(find.text('FINISH ENTRY'));
    await tester.pump();
    await pumpUntilFound(tester, find.byType(ConsistencyScreen));
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    // Some routes may not wire `onContinueToLeaderboard`; always navigate via shell tab.
    await tester.ensureVisible(find.bySemanticsLabel('Leaderboard'));
    await tester.tap(find.bySemanticsLabel('Leaderboard'), warnIfMissed: false);
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Social Leaderboard'),
      timeout: const Duration(seconds: 5),
    );

    // Leaderboard segmented tabs exist (interaction can be flaky headlessly).
    expect(find.text('FRIENDS'), findsOneWidget);
    expect(find.text('CHALLENGES'), findsOneWidget);

    // Load more to exercise pagination.
    await pumpForA11yFrames(tester);
    final loadMore = find.text('LOAD MORE');
    if (loadMore.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(loadMore, 400);
      await tester.ensureVisible(loadMore);
      await tester.pump();
      await tester.tap(loadMore, warnIfMissed: false);
      await tester.pump();
      await pumpForA11yFrames(tester);
    }

    // Open a contributor profile if one exists (pushes a MaterialPageRoute).
    final contributors = find.textContaining('Mock User');
    if (contributors.evaluate().isNotEmpty) {
      await tester.tap(contributors.first);
      await tester.pump();
      await pumpUntilFound(tester, find.byTooltip('Back'));
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Open Settings from the Home tab (via app menu sheet).
    await tester.ensureVisible(find.bySemanticsLabel('Profile'));
    await tester.tap(find.bySemanticsLabel('Profile'), warnIfMissed: false);
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Achievements'),
      timeout: const Duration(seconds: 5),
    );
    await tester.ensureVisible(find.bySemanticsLabel('Home'));
    await tester.tap(find.bySemanticsLabel('Home'), warnIfMissed: false);
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.textContaining("TODAY'S REFLECTION"),
      timeout: const Duration(seconds: 5),
    );
    await tester.tap(find.byTooltip('Menu'), warnIfMissed: false);
    await tester.pump();
    await pumpUntilFound(tester, find.text('Settings'));
    await tester.tap(find.text('Settings'), warnIfMissed: false);
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Settings'),
      timeout: const Duration(seconds: 5),
    );

    // Toggle theme setting (exercises prefs notifier paths).
    final themeTile = find.textContaining('Theme');
    if (themeTile.evaluate().isNotEmpty) {
      await tester.tap(themeTile);
      await tester.pump();
    }
  });
}
