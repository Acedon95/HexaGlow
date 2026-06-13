import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexaglow_app/services/hex_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('rotation', () {
    test('rotateHex cycles through 12 steps (30° increments) and wraps', () async {
      final provider = HexStateProvider();
      await provider.init();

      expect(provider.rotationFor(1), 0);

      for (var i = 1; i <= 11; i++) {
        await provider.rotateHex(1);
        expect(provider.rotationFor(1), i);
      }

      await provider.rotateHex(1);
      expect(provider.rotationFor(1), 0);
    });

    test('rotation is persisted across instances', () async {
      final provider = HexStateProvider();
      await provider.init();
      await provider.rotateHex(3);
      await provider.rotateHex(3);

      final reloaded = HexStateProvider();
      await reloaded.init();
      expect(reloaded.rotationFor(3), 2);
    });
  });

  group('presets', () {
    test('save, apply, and delete a preset', () async {
      final provider = HexStateProvider();
      await provider.init();

      await provider.sendColorHex(1, Colors.red);
      await provider.sendColorEdge(2, 3, Colors.blue);
      await provider.sendBrightness(100);

      await provider.saveCurrentAsPreset('Test preset');
      expect(provider.presets, hasLength(1));
      expect(provider.presets.first.name, 'Test preset');

      await provider.sendClear();
      await provider.sendBrightness(0);

      await provider.applyPreset(provider.presets.first);
      expect(provider.hexStateFor(1).wholeColor, Colors.red);
      expect(provider.hexStateFor(2).edgeColors[3], Colors.blue);
      expect(provider.brightness, 100);

      await provider.deletePreset('Test preset');
      expect(provider.presets, isEmpty);
    });

    test('presets persist across instances', () async {
      final provider = HexStateProvider();
      await provider.init();
      await provider.saveCurrentAsPreset('Saved');

      final reloaded = HexStateProvider();
      await reloaded.init();
      expect(reloaded.presets.map((p) => p.name), contains('Saved'));
    });
  });
}
