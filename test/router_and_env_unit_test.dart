import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/src/core/env/app_env.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/routing/app_router.dart';
import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('routing', () {
    test('authRedirectForState: signed out -> sign-in', () {
      final r = authRedirectForState(
        signedIn: false,
        verified: false,
        uri: Uri.parse('/home'),
      );
      expect(r, '/auth/sign-in');
    });

    test('authRedirectForState: signed in unverified -> verify-email', () {
      final r = authRedirectForState(
        signedIn: true,
        verified: false,
        uri: Uri.parse('/home'),
      );
      expect(r, '/auth/verify-email');
    });

    test('authRedirectForState: signed in verified in auth -> home', () {
      final r = authRedirectForState(
        signedIn: true,
        verified: true,
        uri: Uri.parse('/auth/sign-in'),
      );
      expect(r, '/home');
    });

    test('authRedirectForState: no redirect when already correct', () {
      final r = authRedirectForState(
        signedIn: true,
        verified: true,
        uri: Uri.parse('/leaderboard'),
      );
      expect(r, isNull);
    });
  });

  group('env', () {
    test('appEnvForFlavor: dev defaults', () {
      final env = appEnvForFlavor(AppFlavor.dev);
      expect(env.isDev, true);
      expect(env.appName, contains('Dev'));
      expect(env.emulatorHost, isNotEmpty);
    });

    test('appEnvForFlavor: prod forces mock off', () {
      final env = appEnvForFlavor(AppFlavor.prod);
      expect(env.isProd, true);
      expect(env.useMockData, false);
    });
  });

  group('prefs', () {
    test('AppPrefs clamps reminder time and persists', () async {
      SharedPreferences.setMockInitialValues({
        'pref_daily_reminder_hour': 99,
        'pref_daily_reminder_minute': -1,
      });
      final sp = await SharedPreferences.getInstance();
      final prefs = AppPrefs(sp);

      final time = prefs.dailyReminderTime;
      expect(time.hour, 23);
      expect(time.minute, 0);

      await prefs.setDailyReminderTime(const TimeOfDay(hour: 7, minute: 30));
      final next = prefs.dailyReminderTime;
      expect(next.hour, 7);
      expect(next.minute, 30);
    });
  });
}
