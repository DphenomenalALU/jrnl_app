import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------
const _kThemeMode = 'pref_theme_mode'; // 'light' | 'dark' | 'system'
const _kVoiceAutoTranscribe = 'pref_voice_auto_transcribe'; // bool
const _kDailyReminderEnabled = 'pref_daily_reminder_enabled'; // bool

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
  bool get voiceAutoTranscribe =>
      _prefs.getBool(_kVoiceAutoTranscribe) ?? true;

  Future<void> setVoiceAutoTranscribe(bool value) =>
      _prefs.setBool(_kVoiceAutoTranscribe, value);

  // -- Daily reminder --------------------------------------------------------
  bool get dailyReminderEnabled =>
      _prefs.getBool(_kDailyReminderEnabled) ?? false;

  Future<void> setDailyReminderEnabled(bool value) =>
      _prefs.setBool(_kDailyReminderEnabled, value);
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provides the raw SharedPreferences instance.
/// Override in bootstrap after awaiting [SharedPreferences.getInstance()].
final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in bootstrap.');
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

final dailyReminderProvider =
    NotifierProvider<DailyReminderNotifier, bool>(DailyReminderNotifier.new);
