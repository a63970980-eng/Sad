import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive key/value preferences (theme, locale, notif toggle).
class PrefsService {
  PrefsService(this._prefs);
  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale_code';
  static const _kNotifications = 'notifications_enabled';

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String v) => _prefs.setString(_kThemeMode, v);

  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String v) => _prefs.setString(_kLocale, v);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotifications, v);
}

/// Overridden in main() once SharedPreferences is loaded.
final prefsServiceProvider = Provider<PrefsService>((ref) {
  throw UnimplementedError('prefsServiceProvider must be overridden in main()');
});
