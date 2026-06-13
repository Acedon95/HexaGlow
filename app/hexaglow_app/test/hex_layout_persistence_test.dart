import 'package:flutter_test/flutter_test.dart';
import 'package:hexaglow_app/models/hex_layout.dart';
import 'package:hexaglow_app/utils/default_layout.dart';

void main() {
  group('HexPosition', () {
    test('toJson/fromJson round trip', () {
      const pos = HexPosition(hexIndex: 4, dx: 12.5, dy: -7.25, rotation: 3);
      final restored = HexPosition.fromJson(pos.toJson());

      expect(restored.hexIndex, pos.hexIndex);
      expect(restored.dx, pos.dx);
      expect(restored.dy, pos.dy);
      expect(restored.rotation, pos.rotation);
    });

    test('fromJson defaults rotation to 0 when missing', () {
      final restored = HexPosition.fromJson({'hexIndex': 2, 'dx': 1.0, 'dy': 2.0});

      expect(restored.rotation, 0);
    });

    test('copyWith updates only the given fields', () {
      const pos = HexPosition(hexIndex: 1, dx: 10, dy: 20);
      final moved = pos.copyWith(dx: 15);

      expect(moved.hexIndex, 1);
      expect(moved.dx, 15);
      expect(moved.dy, 20);
      expect(moved.rotation, 0);
    });

    test('copyWith can set rotation to 0', () {
      const pos = HexPosition(hexIndex: 1, dx: 10, dy: 20, rotation: 5);
      final rotated = pos.copyWith(rotation: 0);

      expect(rotated.rotation, 0);
    });
  });

  group('defaultLayout', () {
    test('produces 7 unique hexagons indexed 1-7', () {
      final layout = defaultLayout();

      expect(layout, hasLength(7));
      expect(layout.map((p) => p.hexIndex).toSet(), {1, 2, 3, 4, 5, 6, 7});
    });
  });
}
