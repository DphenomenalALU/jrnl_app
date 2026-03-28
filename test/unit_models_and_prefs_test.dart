import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';

void main() {
  group('AppPrefs', () {
    test('defaults are stable', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final appPrefs = AppPrefs(prefs);

      expect(appPrefs.themeMode, ThemeMode.system);
      expect(appPrefs.voiceAutoTranscribe, isTrue);
      expect(appPrefs.dailyReminderEnabled, isFalse);
      expect(appPrefs.dailyReminderTime, const TimeOfDay(hour: 20, minute: 0));
    });

    test('setters persist and reload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final appPrefs = AppPrefs(prefs);

      await appPrefs.setThemeMode(ThemeMode.dark);
      await appPrefs.setVoiceAutoTranscribe(false);
      await appPrefs.setDailyReminderEnabled(true);
      await appPrefs.setDailyReminderTime(const TimeOfDay(hour: 7, minute: 30));

      final reloaded = AppPrefs(prefs);
      expect(reloaded.themeMode, ThemeMode.dark);
      expect(reloaded.voiceAutoTranscribe, isFalse);
      expect(reloaded.dailyReminderEnabled, isTrue);
      expect(reloaded.dailyReminderTime, const TimeOfDay(hour: 7, minute: 30));
    });
  });

  group('JournalEntry', () {
    test('toFirestore includes required keys', () {
      final entry = JournalEntry(
        id: 'e1',
        uid: 'u1',
        mode: JournalEntryMode.text,
        promptText: 'Prompt',
        bodyText: 'Body',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        energyIndex: null,
        moodIndex: 2,
        internalIndex: 4,
      );

      final map = entry.toFirestore();
      expect(map['mode'], 'text');
      expect(map['promptText'], 'Prompt');
      expect(map['bodyText'], 'Body');
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('updatedAt'), isTrue);
      expect(map['moodIndex'], 2);
      expect(map['internalIndex'], 4);
    });
  });
}
