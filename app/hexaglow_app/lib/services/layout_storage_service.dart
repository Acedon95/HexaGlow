import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/hex_layout.dart';

/// Persists the freely-arranged hexagon canvas layout.
class LayoutStorageService {
  static const _key = 'hex_layout_v1';

  /// Returns `null` if no layout has been saved yet.
  Future<List<HexPosition>?> loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;

    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => HexPosition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLayout(List<HexPosition> positions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(positions.map((p) => p.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
