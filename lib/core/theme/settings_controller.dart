import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs_service.dart';

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.notificationsEnabled,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsController extends Notifier<AppSettings> {
  late final PrefsService _prefs;

  @override
  AppSettings build() {
    _prefs = ref.read(prefsServiceProvider);

    final themeStr = _prefs.themeMode;
    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // Arabic is the default language.
    final localeCode = _prefs.localeCode ?? 'ar';

    return AppSettings(
      themeMode: themeMode,
      locale: Locale(localeCode),
      notificationsEnabled: _prefs.notificationsEnabled,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setThemeMode(mode.name);
  }

  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _prefs.setLocaleCode(locale.languageCode);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setNotificationsEnabled(enabled);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
