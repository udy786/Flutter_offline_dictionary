import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/language.dart';

/// App settings state
class AppSettings {
  final ThemeMode themeMode;
  final LanguagePair languagePair;
  final double fontSize;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languagePair = LanguagePair.englishToHindi,
    this.fontSize = 1.0, // 1.0 is normal, 0.8 small, 1.2 large
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    LanguagePair? languagePair,
    double? fontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languagePair: languagePair ?? this.languagePair,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

/// Settings notifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences? _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  static const _themeModeKey = 'theme_mode';
  static const _sourceLanguageKey = 'source_language';
  static const _targetLanguageKey = 'target_language';
  static const _fontSizeKey = 'font_size';

  void _loadSettings() {
    if (_prefs == null) return;

    final themeModeIndex = _prefs!.getInt(_themeModeKey) ?? 0;
    final sourceLanguage = _prefs!.getString(_sourceLanguageKey) ?? 'en';
    final targetLanguage = _prefs!.getString(_targetLanguageKey) ?? 'hi';
    final fontSize = _prefs!.getDouble(_fontSizeKey) ?? 1.0;

    final source = Language.fromCode(sourceLanguage) ?? Language.english;
    final target = Language.fromCode(targetLanguage) ?? Language.hindi;

    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      languagePair: LanguagePair(source: source, target: target),
      fontSize: fontSize,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs?.setInt(_themeModeKey, mode.index);
  }

  Future<void> setLanguagePair(LanguagePair pair) async {
    state = state.copyWith(languagePair: pair);
    await _prefs?.setString(_sourceLanguageKey, pair.source.code);
    await _prefs?.setString(_targetLanguageKey, pair.target.code);
  }

  Future<void> swapLanguages() async {
    final swapped = state.languagePair.swap();
    await setLanguagePair(swapped);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _prefs?.setDouble(_fontSizeKey, size);
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider for settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  return SettingsNotifier(prefs);
});

/// Provider for current language pair
final languagePairProvider = Provider<LanguagePair>((ref) {
  return ref.watch(settingsProvider).languagePair;
});

/// Provider for source language
final sourceLanguageProvider = Provider<Language>((ref) {
  return ref.watch(languagePairProvider).source;
});

/// Provider for target language
final targetLanguageProvider = Provider<Language>((ref) {
  return ref.watch(languagePairProvider).target;
});
