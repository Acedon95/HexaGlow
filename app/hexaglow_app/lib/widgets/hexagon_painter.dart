import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/hex_geometry.dart';

/// Paints a flat-top hexagon: a filled interior in [wholeColor] and 6
/// colored edge segments ([edgeColors], edge `i` runs from corner `i` to
/// corner `(i + 1) % 6`), matching the firmware's `COLOREDGE` numbering.
///
/// [rotation] (0-11) visually rotates the whole hexagon - outline, fill,
/// edge colors, and edge number labels - by `rotation * 30` degrees around
/// its center, so the on-screen orientation can match how the physical
/// module is actually mounted (e.g. flat-top vs. pointy-top). The hexagon
/// index label in the center is kept upright.
class HexagonPainter extends CustomPainter {
  HexagonPainter({
    required this.wholeColor,
    required this.edgeColors,
    required this.hexIndex,
    this.rotation = 0,
    this.selected = false,
    this.showEdgeLabels = false,
  }) : assert(edgeColors.length == 6);

  final Color wholeColor;
  final List<Color> edgeColors;
  final int hexIndex;
  final int rotation;
  final bool selected;
  final bool showEdgeLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 30 * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

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

    // Edge slot numbers (0-5), shown in the detail view ([selected]) and
    // while arranging the layout ([showEdgeLabels]), but otherwise hidden
    // to keep the overview uncluttered. They rotate together with the
    // hexagon, so each number stays attached to its edge.
    if (selected || showEdgeLabels) {
      final edgeLabelStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.2,
        shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
      );
      for (var i = 0; i < 6; i++) {
        final midpoint = Offset(
          (corners[i].dx + corners[(i + 1) % 6].dx) / 2,
          (corners[i].dy + corners[(i + 1) % 6].dy) / 2,
        );
        final edgeLabelPainter = TextPainter(
          text: TextSpan(text: '$i', style: edgeLabelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        edgeLabelPainter.paint(
          canvas,
          midpoint - Offset(edgeLabelPainter.width / 2, edgeLabelPainter.height / 2),
        );
      }
    }

    canvas.restore();

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
