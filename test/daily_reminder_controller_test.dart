import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jrnl_app/src/core/di/providers.dart';
import 'package:jrnl_app/src/core/env/app_flavor.dart';
import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/src/features/settings/presentation/daily_reminder_controller.dart';

import 'fakes/fake_notifications_service.dart';

void main() {
  test('enabling daily reminder schedules at saved time', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final fakeNotifications = FakeNotificationsService(permissionGranted: true);

    final container = ProviderContainer(
      overrides: [
        appFlavorProvider.overrideWithValue(AppFlavor.dev),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationsServiceProvider.overrideWithValue(fakeNotifications),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(dailyReminderTimeProvider.notifier)
        .set(const TimeOfDay(hour: 7, minute: 15));

    final result = await container
        .read(dailyReminderControllerProvider)
        .setEnabled(true);

    expect(result, DailyReminderResult.enabled);
    expect(container.read(dailyReminderProvider), isTrue);
    expect(
      fakeNotifications.scheduledTime,
      const TimeOfDay(hour: 7, minute: 15),
    );
  });

  test('permission denied does not enable reminder', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final fakeNotifications = FakeNotificationsService(
      permissionGranted: false,
    );

    final container = ProviderContainer(
      overrides: [
        appFlavorProvider.overrideWithValue(AppFlavor.dev),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationsServiceProvider.overrideWithValue(fakeNotifications),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(dailyReminderControllerProvider)
        .setEnabled(true);

    expect(result, DailyReminderResult.permissionDenied);
    expect(container.read(dailyReminderProvider), isFalse);
    expect(fakeNotifications.scheduledTime, isNull);
  });

  test('changing time while enabled reschedules', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final fakeNotifications = FakeNotificationsService(permissionGranted: true);

    final container = ProviderContainer(
      overrides: [
        appFlavorProvider.overrideWithValue(AppFlavor.dev),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationsServiceProvider.overrideWithValue(fakeNotifications),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dailyReminderControllerProvider).setEnabled(true);
    expect(
      fakeNotifications.scheduledTime,
      const TimeOfDay(hour: 20, minute: 0),
    );

    await container
        .read(dailyReminderControllerProvider)
        .setTime(const TimeOfDay(hour: 9, minute: 0));

    expect(
      container.read(dailyReminderTimeProvider),
      const TimeOfDay(hour: 9, minute: 0),
    );
    expect(
      fakeNotifications.scheduledTime,
      const TimeOfDay(hour: 9, minute: 0),
    );
  });
}
