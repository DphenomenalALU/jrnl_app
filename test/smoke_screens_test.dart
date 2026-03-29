import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jrnl_app/screens/ai_insights_screen.dart';
import 'package:jrnl_app/screens/consistency_screen.dart';
import 'package:jrnl_app/screens/edit_profile_screen.dart';
import 'package:jrnl_app/screens/entry_summary_screen.dart';
import 'package:jrnl_app/screens/home_screen.dart';
import 'package:jrnl_app/screens/journal_screen.dart';
import 'package:jrnl_app/screens/leaderboard_screen.dart';
import 'package:jrnl_app/screens/profile_screen.dart';
import 'package:jrnl_app/screens/settings_screen.dart';
import 'package:jrnl_app/screens/user_profile_screen.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/src/features/home/domain/home_insights.dart';
import 'package:jrnl_app/src/features/home/presentation/home_insights_provider.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';
import 'package:jrnl_app/src/features/journal/presentation/insights_provider.dart';
import 'package:jrnl_app/src/features/prompts/domain/prompt.dart';
import 'package:jrnl_app/src/features/prompts/presentation/latest_prompt_provider.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';

void main() {
  Future<SharedPreferences> prefsInstance() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  List<Override> baseOverrides({
    required SharedPreferences prefs,
    required AppUser user,
  }) {
    final prompt = Prompt(
      id: 'p1',
      text: 'Test prompt?',
      date: DateTime(2026, 1, 1),
      active: true,
    );

    final insights = HomeInsights(
      observationTitle: 'PATTERN IDENTIFIED',
      observationBody: 'You tend to write more when you feel calm.',
      baseline: const EmotionalBaseline(
        sampleSize: 3,
        energyLabel: 'Balanced',
        moodLabel: 'Steady',
        internalLabel: 'Focused',
        summary: 'Overall, you seem steady and grounded.',
      ),
    );

    return [
      appFlavorProvider.overrideWithValue(AppFlavor.dev),
      sharedPreferencesProvider.overrideWithValue(prefs),
      // Prefer mock repos/services unless a test explicitly needs Firestore.
      useMockDataProvider.overrideWithValue(true),
      currentUidProvider.overrideWithValue(user.uid),
      currentAppUserProvider.overrideWith((ref) => Stream.value(user)),
      latestPromptProvider.overrideWith((ref) => Stream.value(prompt)),
      homeInsightsProvider.overrideWith((ref) => Stream.value(insights)),
    ];
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required SharedPreferences prefs,
    required List<Override> overrides,
    required Widget child,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('smoke: builds major screens', (tester) async {
    final prefs = await prefsInstance();
    final user = AppUser(
      uid: 'testUid',
      displayName: 'Test User',
      xpTotal: 120,
      streakCount: 7,
      tier: 'Tier 2',
      photoUrl: null,
      bio: 'Hello',
      location: 'Somewhere',
      createdAt: DateTime(2026, 1, 1),
    );

    final overrides = baseOverrides(prefs: prefs, user: user);

    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const HomeScreen(),
    );
    expect(find.textContaining('TODAY'), findsWidgets);

    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const LeaderboardScreen(),
    );
    // Leaderboard uses an async controller; give it a little time.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Social Leaderboard'), findsOneWidget);

    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const ProfileScreen(),
    );
    expect(find.text('Achievements'), findsOneWidget);

    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const SettingsScreen(),
    );
    expect(find.text('Settings'), findsOneWidget);

    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const JournalScreen(),
    );
    expect(find.textContaining('DONE'), findsWidgets);

    // Entry summary + consistency flow.
    await pumpScreen(
      tester,
      prefs: prefs,
      overrides: overrides,
      child: const EntrySummaryScreen(entryId: 'e1'),
    );
    expect(find.text('Entry Summary'), findsOneWidget);
    await tester.ensureVisible(find.text('FINISH ENTRY'));
    await tester.tap(find.text('FINISH ENTRY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // Consistency screen pushed.
    expect(find.byType(ConsistencyScreen), findsOneWidget);
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Entry Summary'), findsOneWidget);

    // User profile + open edit modal.
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: UserProfileScreen(mode: UserProfileMode.me),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byTooltip('Edit profile'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(EditProfileScreen), findsOneWidget);

    // AI insights screen (override entry stream).
    final entry = JournalEntry(
      id: 'e1',
      uid: user.uid,
      mode: JournalEntryMode.voice,
      promptText: 'Prompt',
      bodyText: 'Body',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      energyIndex: null,
      moodIndex: null,
      internalIndex: null,
      transcript: 'Transcript',
      aiInsight: 'Insight',
      status: EntryStatus.done,
    );
    // New ProviderScope instance: Riverpod forbids changing override *count* on update.
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey<String>('smoke-ai-insights'),
        overrides: [
          ...overrides,
          insightsEntryProvider.overrideWith(
            (ref, entryId) => Stream.value(entry),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AiInsightsScreen(entryId: 'e1')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('AI INSIGHTS'), findsWidgets);
  });
}
