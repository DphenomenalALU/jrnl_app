import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/src/core/routing/app_router.dart';

void main() {
  group('authRedirectForState', () {
    test('signed out -> non-auth routes redirect to sign-in', () {
      final next = authRedirectForState(
        signedIn: false,
        verified: false,
        uri: Uri.parse('/home'),
      );
      expect(next, '/auth/sign-in');
    });

    test('signed out -> auth routes stay', () {
      final next = authRedirectForState(
        signedIn: false,
        verified: false,
        uri: Uri.parse('/auth/sign-in'),
      );
      expect(next, isNull);
    });

    test('signed in, unverified -> redirect to verify-email', () {
      final next = authRedirectForState(
        signedIn: true,
        verified: false,
        uri: Uri.parse('/home'),
      );
      expect(next, '/auth/verify-email');
    });

    test('signed in, verified -> auth routes redirect to home', () {
      final next = authRedirectForState(
        signedIn: true,
        verified: true,
        uri: Uri.parse('/auth/sign-in'),
      );
      expect(next, '/home');
    });
  });
}
