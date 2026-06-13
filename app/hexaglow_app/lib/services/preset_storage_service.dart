import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/color_preset.dart';

/// Persists named [ColorPreset]s.
class PresetStorageService {
  static const _key = 'color_presets_v1';

  /// Returns an empty list if no presets have been saved yet.
  Future<List<ColorPreset>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => ColorPreset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePresets(List<ColorPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(presets.map((p) => p.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
