import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jrnl_app/src/features/auth/presentation/reset_password_screen.dart';
import 'package:jrnl_app/src/features/auth/presentation/sign_in_screen.dart';
import 'package:jrnl_app/src/features/auth/presentation/sign_up_screen.dart';

void main() {
  testWidgets('auth screens: build + validators + navigation', (tester) async {
    final router = GoRouter(
      initialLocation: '/auth/sign-in',
      routes: [
        GoRoute(
          path: '/auth/sign-in',
          builder: (_, _) => const SignInScreen(),
        ),
        GoRoute(
          path: '/auth/sign-up',
          builder: (_, _) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/auth/reset-password',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            return ResetPasswordScreen(initialEmail: email);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Sign-in validators (no Firebase calls).
    expect(find.text('Welcome back.'), findsOneWidget);
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'bad');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);

    // Forgot password navigates (passes email query param when present).
    await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    // Return to sign-in before navigating to sign-up.
    router.go('/auth/sign-in');
    await tester.pumpAndSettle();

    // Go to sign-up and validate.
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account.'), findsOneWidget);
    await tester.tap(find.text('SIGN UP'));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });
}
