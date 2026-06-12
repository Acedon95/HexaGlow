import 'dart:math' as math;

import '../models/hex_layout.dart';

/// Logical size of the draggable hexagon widgets (width == height).
const double kHexBoxSize = 100.0;

/// Logical size of the square canvas the hexagons are placed on.
const double kCanvasSize = 1000.0;

/// Default arrangement: hexagon 1 centered, hexagons 2-7 forming a ring
/// around it - a "flower" of 7 hexagons, a common honeycomb cluster shape.
///
/// This is only a starting point; positions are draggable and persisted
/// once the user arranges them to match their physical build.
List<HexPosition> defaultLayout() {
  const centerDx = kCanvasSize / 2 - kHexBoxSize / 2;
  const centerDy = kCanvasSize / 2 - kHexBoxSize / 2;

  final positions = <HexPosition>[
    const HexPosition(hexIndex: 1, dx: centerDx, dy: centerDy),
  ];

  const distance = kHexBoxSize * 0.95;
  for (var i = 0; i < 6; i++) {
    final angle = (60.0 * i - 90.0) * math.pi / 180.0;
    final dx = centerDx + distance * math.cos(angle);
    final dy = centerDy + distance * math.sin(angle);
    positions.add(HexPosition(hexIndex: i + 2, dx: dx, dy: dy));
  }

  return positions;
}
