import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/screens/consistency_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/presentation/widgets/jrnl_bottom_nav.dart';
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
    await pumpUntilFound(tester, find.textContaining("TODAY'S REFLECTION"));

    // Home -> Journal via CTA (covers `onStartJournaling` callback).
    await tester.tap(find.text('START JOURNALING'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('EXPLORE DEEPLY'));

    // Save a text entry (covers optimistic UI + navigation to Entry Summary).
    await tester.enterText(
      find.byType(TextField).first,
      'Today I tested the app end-to-end.',
    );
    await tester.tap(find.text('DONE'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Entry Summary'));

    // Entry Summary -> Consistency -> Continue (pops + switches tab to leaderboard).
    await tester.ensureVisible(find.text('FINISH ENTRY'));
    await tester.tap(find.text('FINISH ENTRY'));
    await tester.pump();
    await pumpUntilFound(tester, find.byType(ConsistencyScreen));
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Social Leaderboard'));

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

    // Open a contributor profile (pushes a MaterialPageRoute).
    final anyContributor = find.textContaining('Mock User').first;
    if (anyContributor.evaluate().isNotEmpty) {
      await tester.tap(anyContributor);
      await tester.pump();
      await pumpUntilFound(tester, find.byTooltip('Back'));
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Bottom nav: Profile -> Settings (tap full InkWell — Semantics hug the small SVG only).
    final profileTab = find.descendant(
      of: find.byType(JrnlBottomNav),
      matching: find.byType(InkWell),
    );
    await tester.tap(profileTab.at(3));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Achievements'));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Settings'));

    // Toggle theme setting (exercises prefs notifier paths).
    final themeTile = find.textContaining('Theme');
    if (themeTile.evaluate().isNotEmpty) {
      await tester.tap(themeTile);
      await tester.pump();
    }
  });
}
