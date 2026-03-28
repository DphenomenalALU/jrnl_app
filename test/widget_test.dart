// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/screens/settings_screen.dart';

void main() {
  testWidgets('Settings loads with defaults', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appFlavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Auto-transcribe'), findsOneWidget);
    expect(find.text('Daily reminder'), findsOneWidget);
  });
}
