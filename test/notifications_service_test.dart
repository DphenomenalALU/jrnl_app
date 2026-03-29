import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/src/core/services/notifications_service.dart';

void main() {
  test('NoopNotificationsService completes without side effects', () async {
    const svc = NoopNotificationsService();
    expect(await svc.requestPermissions(), true);
    await svc.scheduleDailyReminder(time: const TimeOfDay(hour: 9, minute: 0));
    await svc.cancelDailyReminder();
  });
}
