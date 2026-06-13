import 'package:flutter/material.dart';

import '../utils/color_channels.dart';

/// A named snapshot of all 7 hexagons' colors and the global brightness,
/// so the user can recreate a look later.
class ColorPreset {
  final String name;

  /// Whole-hexagon fill color, index 0 = hexagon 1, length 7.
  final List<Color> wholeColors;

  /// Per-hexagon edge colors in firmware edge order (0-5), length 7x6.
  final List<List<Color>> edgeColors;

  final int brightness;

  const ColorPreset({
    required this.name,
    required this.wholeColors,
    required this.edgeColors,
    required this.brightness,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'wholeColors': wholeColors.map((c) => c.toRgbInt()).toList(),
        'edgeColors':
            edgeColors.map((edges) => edges.map((c) => c.toRgbInt()).toList()).toList(),
        'brightness': brightness,
      };

  factory ColorPreset.fromJson(Map<String, dynamic> json) => ColorPreset(
        name: json['name'] as String,
        wholeColors:
            (json['wholeColors'] as List).map((v) => colorFromRgbInt(v as int)).toList(),
        edgeColors: (json['edgeColors'] as List)
            .map((edges) => (edges as List).map((v) => colorFromRgbInt(v as int)).toList())
            .toList(),
        brightness: json['brightness'] as int,
      );
}
