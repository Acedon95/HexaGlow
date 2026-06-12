import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/hex_geometry.dart';

/// Paints a flat-top hexagon: a filled interior in [wholeColor] and 6
/// colored edge segments ([edgeColors], edge `i` runs from corner `i` to
/// corner `(i + 1) % 6`), matching the firmware's `COLOREDGE` numbering.
class HexagonPainter extends CustomPainter {
  HexagonPainter({
    required this.wholeColor,
    required this.edgeColors,
    required this.hexIndex,
    this.selected = false,
  }) : assert(edgeColors.length == 6);

  final Color wholeColor;
  final List<Color> edgeColors;
  final int hexIndex;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;
    final corners = hexagonCorners(center, radius);

    final fillPath = Path()..addPolygon(corners, true);
    canvas.drawPath(fillPath, Paint()..color = wholeColor..style = PaintingStyle.fill);

    final edgeStrokeWidth = radius * 0.22;
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        corners[i],
        corners[(i + 1) % 6],
        Paint()
          ..color = edgeColors[i]
          ..strokeWidth = edgeStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = selected ? Colors.white : Colors.grey.shade700
        ..strokeWidth = selected ? 3 : 1
        ..style = PaintingStyle.stroke,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$hexIndex',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          shadows: [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) => true;
}
