import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexaglow_app/models/color_preset.dart';
import 'package:hexaglow_app/utils/color_channels.dart';

void main() {
  group('ColorChannels rgb int', () {
    test('toRgbInt/colorFromRgbInt round trip', () {
      const color = Color(0xFF1A2B3C);
      final restored = colorFromRgbInt(color.toRgbInt());

      expect(restored.r8, color.r8);
      expect(restored.g8, color.g8);
      expect(restored.b8, color.b8);
    });
  });

  group('ColorPreset', () {
    test('toJson/fromJson round trip', () {
      final preset = ColorPreset(
        name: 'Sunset',
        wholeColors: List.generate(7, (i) => Color(0xFF000000 | (i * 0x111111))),
        edgeColors: List.generate(
          7,
          (i) => List.generate(6, (e) => Color(0xFF000000 | ((i * 6 + e) * 0x010101))),
        ),
        brightness: 180,
      );

      final restored = ColorPreset.fromJson(preset.toJson());

      expect(restored.name, preset.name);
      expect(restored.brightness, preset.brightness);
      for (var i = 0; i < 7; i++) {
        expect(restored.wholeColors[i].toRgbInt(), preset.wholeColors[i].toRgbInt());
        for (var e = 0; e < 6; e++) {
          expect(restored.edgeColors[i][e].toRgbInt(), preset.edgeColors[i][e].toRgbInt());
        }
      }
    });
  });
}
