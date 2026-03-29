import 'package:flutter/material.dart';

import 'package:jrnl_app/src/core/services/notifications_service.dart';

class StubNotificationsService implements NotificationsService {
  StubNotificationsService({this.permissionGranted = true});

  bool permissionGranted;
  TimeOfDay? scheduledTime;
  var cancelCount = 0;

  @override
  Future<bool> requestPermissions() async => permissionGranted;

  @override
  Future<void> scheduleDailyReminder({required TimeOfDay time}) async {
    scheduledTime = time;
  }

  @override
  Future<void> cancelDailyReminder() async {
    cancelCount += 1;
    scheduledTime = null;
  }
}
