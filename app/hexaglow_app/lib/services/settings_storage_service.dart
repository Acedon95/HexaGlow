import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Persists the ESP32 connection settings (IP address + UDP port).
class SettingsStorageService {
  static const _key = 'app_settings_v1';

  /// Returns `null` if no settings have been saved yet.
  Future<AppSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;

    return AppSettings.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
