import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------
const _kThemeMode = 'pref_theme_mode'; // 'light' | 'dark' | 'system'
const _kVoiceAutoTranscribe = 'pref_voice_auto_transcribe'; // bool
const _kDailyReminderEnabled = 'pref_daily_reminder_enabled'; // bool
const _kDailyReminderHour = 'pref_daily_reminder_hour'; // int
const _kDailyReminderMinute = 'pref_daily_reminder_minute'; // int

// ---------------------------------------------------------------------------
// AppPrefs — thin wrapper around SharedPreferences
// ---------------------------------------------------------------------------
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  // -- Theme -----------------------------------------------------------------
  ThemeMode get themeMode {
    final raw = _prefs.getString(_kThemeMode) ?? 'system';
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    return _prefs.setString(_kThemeMode, raw);
  }

  // -- Voice auto-transcribe -------------------------------------------------
  bool get voiceAutoTranscribe => _prefs.getBool(_kVoiceAutoTranscribe) ?? true;

  Future<void> setVoiceAutoTranscribe(bool value) =>
      _prefs.setBool(_kVoiceAutoTranscribe, value);

  // -- Daily reminder --------------------------------------------------------
  bool get dailyReminderEnabled =>
      _prefs.getBool(_kDailyReminderEnabled) ?? false;

  Future<void> setDailyReminderEnabled(bool value) =>
      _prefs.setBool(_kDailyReminderEnabled, value);

  TimeOfDay get dailyReminderTime {
    final hour = _prefs.getInt(_kDailyReminderHour);
    final minute = _prefs.getInt(_kDailyReminderMinute);
    if (hour == null || minute == null) {
      return const TimeOfDay(hour: 20, minute: 0);
    }
    final safeHour = hour.clamp(0, 23);
    final safeMinute = minute.clamp(0, 59);
    return TimeOfDay(hour: safeHour, minute: safeMinute);
  }

  Future<void> setDailyReminderTime(TimeOfDay value) async {
    await _prefs.setInt(_kDailyReminderHour, value.hour);
    await _prefs.setInt(_kDailyReminderMinute, value.minute);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provides the raw SharedPreferences instance.
/// Override in bootstrap after awaiting [SharedPreferences.getInstance()].
final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap.',
  );
});

/// Provides the [AppPrefs] wrapper — always available after bootstrap.
final appPrefsProvider = Provider<AppPrefs>((ref) {
  return AppPrefs(ref.watch(sharedPreferencesProvider));
});

// ---------------------------------------------------------------------------
// Notifiers — reactive state for each preference
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(appPrefsProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    await ref.read(appPrefsProvider).setThemeMode(mode);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class VoiceAutoTranscribeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPrefsProvider).voiceAutoTranscribe;

  Future<void> set(bool value) async {
    await ref.read(appPrefsProvider).setVoiceAutoTranscribe(value);
    state = value;
  }
}

final voiceAutoTranscribeProvider =
    NotifierProvider<VoiceAutoTranscribeNotifier, bool>(
      VoiceAutoTranscribeNotifier.new,
    );

class DailyReminderNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPrefsProvider).dailyReminderEnabled;

  Future<void> set(bool value) async {
    await ref.read(appPrefsProvider).setDailyReminderEnabled(value);
    state = value;
  }
}

final dailyReminderProvider = NotifierProvider<DailyReminderNotifier, bool>(
  DailyReminderNotifier.new,
);

class DailyReminderTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() => ref.watch(appPrefsProvider).dailyReminderTime;

  Future<void> set(TimeOfDay value) async {
    await ref.read(appPrefsProvider).setDailyReminderTime(value);
    state = value;
  }
}

final dailyReminderTimeProvider =
    NotifierProvider<DailyReminderTimeNotifier, TimeOfDay>(
      DailyReminderTimeNotifier.new,
    );
