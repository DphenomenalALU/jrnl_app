// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jrnl_app/main.dart';
import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';

void main() {
  testWidgets('JRNL sign-in loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appFlavorProvider.overrideWithValue(AppFlavor.dev),
        ],
        child: const JrnlApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome back.'), findsOneWidget);
    expect(find.textContaining('SIGN IN'), findsOneWidget);
  });
}
