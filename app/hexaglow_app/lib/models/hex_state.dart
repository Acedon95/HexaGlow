import 'package:flutter/material.dart';

/// In-memory, optimistic UI state for a single hexagon.
///
/// The firmware has no read-back protocol, so this only reflects the last
/// color commands sent from this app. It is not persisted - on app restart
/// it resets to black, matching the LEDs' lack of power-on memory.
class HexState {
  final int hexIndex;
  Color wholeColor;
  final List<Color> edgeColors;

  HexState({required this.hexIndex, Color? initialColor})
      : wholeColor = initialColor ?? Colors.black,
        edgeColors = List.generate(6, (_) => initialColor ?? Colors.black);

  /// Sets the central fill color and all 6 edge colors, used when every
  /// pixel of the hexagon is being set to the same color (e.g. [clear]).
  void setWholeColor(Color color) {
    wholeColor = color;
    for (var i = 0; i < edgeColors.length; i++) {
      edgeColors[i] = color;
    }
  }

  /// Sets all 6 edge colors without touching the central fill color, used
  /// for `COLORALL`/`COLORHEX` which address the edge LEDs.
  void setAllEdgeColors(Color color) {
    for (var i = 0; i < edgeColors.length; i++) {
      edgeColors[i] = color;
    }
  }

  void setEdgeColor(int edge, Color color) {
    edgeColors[edge] = color;
  }

  void clear() {
    setWholeColor(Colors.black);
  }
}
