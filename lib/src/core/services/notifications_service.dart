import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class NotificationsService {
  Future<bool> requestPermissions();
  Future<void> scheduleDailyReminder({required TimeOfDay time});
  Future<void> cancelDailyReminder();
}

class NoopNotificationsService implements NotificationsService {
  const NoopNotificationsService();

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleDailyReminder({required TimeOfDay time}) async {}

  @override
  Future<void> cancelDailyReminder() async {}
}

class LocalNotificationsService implements NotificationsService {
  LocalNotificationsService();

  static const int _dailyReminderId = 7001;
  static const String _dailyChannelId = 'daily_reminder';
  static const String _dailyChannelName = 'Daily reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  var _initialized = false;

  Future<void> _initIfNeeded() async {
    if (_initialized) return;

    final android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = const DarwinInitializationSettings();
    await _plugin.initialize(
      InitializationSettings(android: android, iOS: ios),
    );

    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await _initIfNeeded();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final okIos =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    final okMac =
        await mac?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    return okIos && okMac;
  }

  @override
  Future<void> scheduleDailyReminder({required TimeOfDay time}) async {
    await _initIfNeeded();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Daily journal reminder',
      'Take 2 minutes to write something you noticed today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          channelDescription: 'A daily nudge to journal.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDailyReminder() async {
    await _initIfNeeded();
    await _plugin.cancel(_dailyReminderId);
  }
}
