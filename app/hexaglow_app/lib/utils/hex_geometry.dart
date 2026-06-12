import 'dart:math' as math;
import 'dart:ui';

/// Returns the 6 corner points of a flat-top hexagon centered at [center]
/// with the given [radius].
///
/// Corner 0 is the top-right corner; corners proceed clockwise. Edge `i`
/// is the segment from `corners[i]` to `corners[(i + 1) % 6]` and maps to
/// the firmware's `COLOREDGE hex_index <i> r g b` command (edge 0-5).
List<Offset> hexagonCorners(Offset center, double radius) {
  return List.generate(6, (i) {
    final angleDeg = 60.0 * i - 90.0 + 30.0;
    final angleRad = angleDeg * math.pi / 180.0;
    return Offset(
      center.dx + radius * math.cos(angleRad),
      center.dy + radius * math.sin(angleRad),
    );
  });
}
