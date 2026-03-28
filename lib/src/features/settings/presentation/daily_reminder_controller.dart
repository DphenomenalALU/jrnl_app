import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/services/app_prefs.dart';

enum DailyReminderResult { enabled, disabled, permissionDenied }

class DailyReminderController {
  DailyReminderController(this._ref);

  final Ref _ref;

  Future<DailyReminderResult> setEnabled(bool enabled) async {
    if (enabled) {
      final ok = await _ref
          .read(notificationsServiceProvider)
          .requestPermissions();
      if (!ok) return DailyReminderResult.permissionDenied;
    }

    await _ref.read(dailyReminderProvider.notifier).set(enabled);

    if (enabled) {
      final time = _ref.read(dailyReminderTimeProvider);
      await _ref
          .read(notificationsServiceProvider)
          .scheduleDailyReminder(time: time);
      return DailyReminderResult.enabled;
    } else {
      await _ref.read(notificationsServiceProvider).cancelDailyReminder();
      return DailyReminderResult.disabled;
    }
  }

  Future<void> setTime(TimeOfDay time) async {
    await _ref.read(dailyReminderTimeProvider.notifier).set(time);
    final enabled = _ref.read(dailyReminderProvider);
    if (!enabled) return;
    await _ref
        .read(notificationsServiceProvider)
        .scheduleDailyReminder(time: time);
  }
}

final dailyReminderControllerProvider = Provider<DailyReminderController>((
  ref,
) {
  return DailyReminderController(ref);
});
