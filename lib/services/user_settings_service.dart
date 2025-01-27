import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final SharedPreferences _prefs;

  UserSettings(this._prefs);

  AppSettings get appSettings {
    return AppSettings()
      ..isDarkMode = _prefs.getBool('isDarkMode') ?? false
      ..isNotificationEnabled = _prefs.getBool('isNotificationEnabled') ?? true
      ..secureMode = _prefs.getBool('secureMode') ?? true;
  }

  Future<void> asJson() async {
    final settings = appSettings;
    await _prefs.setBool('isDarkMode', settings.isDarkMode);
    await _prefs.setBool(
        'isNotificationEnabled', settings.isNotificationEnabled);
    await _prefs.setBool('secureMode', settings.secureMode);
  }

  void updateAppSettings(AppSettings settings) {
    _prefs.setBool('isDarkMode', settings.isDarkMode);
    _prefs.setBool('isNotificationEnabled', settings.isNotificationEnabled);
    _prefs.setBool('secureMode', settings.secureMode);
  }

  void turnOnSecureMode() {
    _prefs.setBool('secureMode', true);
  }

  void turnOffSecureMode() {
    _prefs.setBool('secureMode', false);
  }
}

class AppSettings {
  bool isDarkMode = false;
  bool isNotificationEnabled = true;
  bool secureMode = true;
}
