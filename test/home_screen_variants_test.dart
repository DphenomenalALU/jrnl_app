import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/screens/home_screen.dart';
import 'package:jrnl_app/src/features/home/presentation/home_insights_provider.dart';

import 'support/test_harness.dart';

void main() {
  testWidgets('HomeScreen: baseline locked copy (no insights)', (tester) async {
    final prefs = await testPrefs();
    final overrides = baseOverrides(prefs: prefs)
      ..add(homeInsightsProvider.overrideWith((ref) => const Stream.empty()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.pump();

    expect(find.textContaining('EMOTIONAL BASELINE'), findsOneWidget);
    expect(find.textContaining('Mock mode is enabled'), findsOneWidget);
  });

  testWidgets('HomeScreen: start journaling callback runs', (tester) async {
    var tapped = 0;
    final prefs = await testPrefs();
    final overrides = baseOverrides(prefs: prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: Scaffold(body: HomeScreen(onStartJournaling: () => tapped++)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('START JOURNALING'));
    await tester.pump();
    expect(tapped, 1);
  });
}
