import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

  import '../models/prayer_history.dart';
  import '../models/prayer_settings.dart';
  import '../models/user_model.dart';

  class LocalStorageService {
    LocalStorageService(this._preferences);

    static const String userKey = 'noor.profile.v1';
    static const String historyKey = 'noor.history.v1';
    static const String prayerSettingsKey = 'noor.prayer_settings.v1';
    static const String themeKey = 'noor.theme.v1';
    static const String welcomeSeenKey = 'noor.welcome_seen.v1';
    static const String celebratedMilestonesKey = 'noor.celebrated_milestones.v1';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  Future<UserModel?> loadUser() async {
    final String? raw = _preferences.getString(userKey);
    if (raw == null) {
      return null;
    }
    try {
      return UserModel.fromJson(jsonDecode(raw));
    } on Object {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _preferences.setString(userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    await _preferences.remove(userKey);
  }

  Future<PrayerHistory> loadHistory() async {
    final String? raw = _preferences.getString(historyKey);
    if (raw == null) {
      return PrayerHistory.empty();
    }
    try {
      return PrayerHistory.fromJson(jsonDecode(raw));
    } on Object {
      return PrayerHistory.empty();
    }
  }

  Future<void> saveHistory(PrayerHistory history) async {
    await _preferences.setString(historyKey, jsonEncode(history.toJson()));
  }

  Future<PrayerSettings> loadPrayerSettings() async {
    final String? raw = _preferences.getString(prayerSettingsKey);
    if (raw == null) {
      return const PrayerSettings();
    }
    try {
      return PrayerSettings.fromJson(jsonDecode(raw));
    } on Object {
      return const PrayerSettings();
    }
  }

  Future<void> savePrayerSettings(PrayerSettings settings) async {
    await _preferences.setString(
      prayerSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  Future<AppThemePreference> loadThemePreference() async {
    return AppThemePreference.fromStorage(_preferences.getString(themeKey));
  }

  Future<void> saveThemePreference(AppThemePreference preference) async {
    await _preferences.setString(themeKey, preference.name);
  }

  Future<bool> loadWelcomeSeen() async {
    return _preferences.getBool(welcomeSeenKey) ?? false;
  }

  Future<void> saveWelcomeSeen() async {
    await _preferences.setBool(welcomeSeenKey, true);
  }

  Future<Set<String>> loadCelebratedMilestones() async {
    final List<String>? raw = _preferences.getStringList(celebratedMilestonesKey);
    if (raw == null) {
      return <String>{};
    }
    return raw.toSet();
  }

  Future<void> saveCelebratedMilestones(Set<String> milestones) async {
    await _preferences.setStringList(
      celebratedMilestonesKey,
      milestones.toList(),
    );
  }

  Future<void> clearAll() async {
    await Future.wait(<Future<bool>>[
      _preferences.remove(userKey),
      _preferences.remove(historyKey),
      _preferences.remove(prayerSettingsKey),
      _preferences.remove(themeKey),
      _preferences.remove(welcomeSeenKey),
      _preferences.remove(celebratedMilestonesKey),
    ]);
  }
}
