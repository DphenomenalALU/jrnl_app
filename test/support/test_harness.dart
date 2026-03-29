import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/src/features/home/domain/home_insights.dart';
import 'package:jrnl_app/src/features/home/presentation/home_insights_provider.dart';
import 'package:jrnl_app/src/features/prompts/domain/prompt.dart';
import 'package:jrnl_app/src/features/prompts/presentation/latest_prompt_provider.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:jrnl_app/src/features/users/presentation/current_app_user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> testPrefs({
  Map<String, Object> initial = const {},
}) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

AppUser testUser({
  String uid = 'testUid',
  String displayName = 'Test User',
  int xpTotal = 120,
  int streakCount = 7,
  String tier = 'Tier 2',
}) {
  return AppUser(
    uid: uid,
    displayName: displayName,
    xpTotal: xpTotal,
    streakCount: streakCount,
    tier: tier,
    photoUrl: null,
    bio: 'Hello',
    location: 'Somewhere',
    createdAt: DateTime(2026, 1, 1),
  );
}

Prompt testPrompt({String id = 'p1', String text = 'Test prompt?'}) {
  return Prompt(id: id, text: text, date: DateTime(2026, 1, 1), active: true);
}

HomeInsights testInsights({EmotionalBaseline? baseline}) {
  return HomeInsights(
    observationTitle: 'PATTERN IDENTIFIED',
    observationBody: 'You tend to write more when you feel calm.',
    baseline:
        baseline ??
        const EmotionalBaseline(
          sampleSize: 3,
          energyLabel: 'Balanced',
          moodLabel: 'Steady',
          internalLabel: 'Focused',
          summary: 'Overall, you seem steady and grounded.',
        ),
  );
}

List<Override> baseOverrides({
  required SharedPreferences prefs,
  AppUser? user,
  Prompt? prompt,
  HomeInsights? insights,
  bool useMockData = true,
}) {
  final u = user ?? testUser();
  return [
    appFlavorProvider.overrideWithValue(AppFlavor.dev),
    sharedPreferencesProvider.overrideWithValue(prefs),
    useMockDataProvider.overrideWithValue(useMockData),
    currentUidProvider.overrideWithValue(u.uid),
    currentAppUserProvider.overrideWith((ref) => Stream.value(u)),
    latestPromptProvider.overrideWith(
      (ref) => Stream.value(prompt ?? testPrompt()),
    ),
    homeInsightsProvider.overrideWith(
      (ref) => Stream.value(insights ?? testInsights()),
    ),
  ];
}

Future<void> pumpForA11yFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Pumps repeatedly until [finder] appears or a short timeout elapses.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 3),
  Duration step = const Duration(milliseconds: 50),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TimeoutException('Timed out waiting for $finder');
}
