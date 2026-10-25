import 'package:flutter/material.dart';

import '../models/prayer_settings.dart';
import '../services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  AppThemePreference _preference = AppThemePreference.system;
  bool _isInitialized = false;

  AppThemePreference get preference => _preference;
  bool get isInitialized => _isInitialized;

  ThemeMode get themeMode {
    switch (_preference) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> initialize() async {
    try {
      _preference = await _storage.loadThemePreference();
    } on Object {
      _preference = AppThemePreference.system;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference == preference) {
      return;
    }
    _preference = preference;
    notifyListeners();
    try {
      await _storage.saveThemePreference(preference);
    } on Object {
      // The preference remains active for this session even if disk access fails.
    }
  }

  void resetLocal() {
    _preference = AppThemePreference.system;
    notifyListeners();
  }
}
