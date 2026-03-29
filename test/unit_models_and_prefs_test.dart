import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jrnl_app/src/core/services/app_prefs.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';
import 'package:jrnl_app/src/features/prompts/domain/prompt.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';

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

    test('dailyReminderTime clamps invalid stored values', () async {
      SharedPreferences.setMockInitialValues({
        'pref_daily_reminder_hour': 99,
        'pref_daily_reminder_minute': -2,
      });
      final prefs = await SharedPreferences.getInstance();
      final appPrefs = AppPrefs(prefs);
      expect(appPrefs.dailyReminderTime, const TimeOfDay(hour: 23, minute: 0));
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

    test('fromMap parses voice fields + status', () {
      final created = DateTime(2026, 1, 1, 12, 0);
      final updated = DateTime(2026, 1, 1, 12, 5);
      final entry = JournalEntry.fromMap(
        uid: 'u1',
        id: 'e1',
        data: <String, dynamic>{
          'mode': 'voice',
          'promptText': 'P',
          'bodyText': 'B',
          'createdAt': Timestamp.fromDate(created),
          'updatedAt': Timestamp.fromDate(updated),
          'status': 'transcribing',
          'audioUrl': 'https://example.com/audio.m4a',
        },
      );
      expect(entry.mode, JournalEntryMode.voice);
      expect(entry.status, EntryStatus.transcribing);
      expect(entry.audioUrl, isNotNull);
      expect(entry.createdAt, created);
      expect(entry.updatedAt, updated);
    });

    test('fromMap falls back for unknown status', () {
      final entry = JournalEntry.fromMap(
        uid: 'u1',
        id: 'e1',
        data: <String, dynamic>{
          'mode': 'text',
          'promptText': 'P',
          'bodyText': 'B',
          'status': '???',
        },
      );
      expect(entry.status, EntryStatus.draft);
    });

    test('toFirestore writes status string', () {
      final entry = JournalEntry(
        id: 'e1',
        uid: 'u1',
        mode: JournalEntryMode.voice,
        promptText: 'Prompt',
        bodyText: 'Body',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        energyIndex: 1,
        moodIndex: 2,
        internalIndex: 3,
        status: EntryStatus.transcribed,
      );
      final map = entry.toFirestore();
      expect(map['status'], 'transcribed');
      expect(map['mode'], 'voice');
    });
  });

  group('Freezed models', () {
    test('Prompt.fromJson parses timestamps', () {
      final prompt = Prompt.fromJson(<String, dynamic>{
        'id': 'p1',
        'text': 'Hello',
        'date': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'active': true,
      });
      expect(prompt.id, 'p1');
      expect(prompt.text, 'Hello');
      expect(prompt.active, isTrue);
      expect(prompt.date, isA<DateTime>());
    });

    test('AppUser.fromJson parses timestamps', () {
      final user = AppUser.fromJson(<String, dynamic>{
        'uid': 'u1',
        'displayName': 'Name',
        'xpTotal': 12,
        'streakCount': 3,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      expect(user.uid, 'u1');
      expect(user.displayName, 'Name');
      expect(user.xpTotal, 12);
      expect(user.streakCount, 3);
      expect(user.createdAt, isNotNull);
    });
  });
}
