import 'package:flutter/material.dart';

import '../models/hex_state.dart';
import 'hexagon_painter.dart';

/// Visual representation of a single hexagon, showing its whole-hex fill
/// color and the 6 individually-colorable edges.
///
/// This widget is presentation-only; dragging and tap handling are wired up
/// by the caller (see `HomeScreen`) so layout state stays in one place.
class HexagonWidget extends StatelessWidget {
  const HexagonWidget({
    super.key,
    required this.state,
    this.size = 100,
    this.selected = false,
  });

  final HexState state;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HexagonPainter(
          wholeColor: state.wholeColor,
          edgeColors: state.edgeColors,
          hexIndex: state.hexIndex,
          selected: selected,
        ),
      ),
    );
  }
}
