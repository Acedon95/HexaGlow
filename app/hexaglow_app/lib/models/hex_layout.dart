/// Position of a single hexagon on the freely-arrangeable canvas.
///
/// [hexIndex] is the 1-based index used throughout the app and matches the
/// firmware's `hex_index` convention (1-7), so it never needs adjusting
/// before being sent over UDP.
class HexPosition {
  final int hexIndex;
  final double dx;
  final double dy;

  /// Number of 30-degree clockwise visual rotation steps applied to this
  /// hexagon's graphic (outline, fill, edge colors, edge labels) on screen
  /// (0-11).
  ///
  /// This is purely cosmetic and lets the on-screen orientation match how
  /// the physical module is actually mounted; firmware edge indices are
  /// unaffected.
  final int rotation;

  /// Number of 60-degree clockwise steps applied to this hexagon's edge
  /// indices before they're sent to the firmware (0-5).
  ///
  /// The UI always draws "edge 0" at the top-right of the hexagon (before
  /// [rotation] is applied); this offset lets that fixed visual slot map to
  /// whichever physical edge is actually wired there, to account for
  /// differing cable orientations.
  final int edgeRotation;

  const HexPosition({
    required this.hexIndex,
    required this.dx,
    required this.dy,
    this.rotation = 0,
    this.edgeRotation = 0,
  });

  HexPosition copyWith({double? dx, double? dy, int? rotation, int? edgeRotation}) {
    return HexPosition(
      hexIndex: hexIndex,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      rotation: rotation ?? this.rotation,
      edgeRotation: edgeRotation ?? this.edgeRotation,
    );
  }

  Map<String, dynamic> toJson() => {
        'hexIndex': hexIndex,
        'dx': dx,
        'dy': dy,
        'rotation': rotation,
        'edgeRotation': edgeRotation,
      };

  factory HexPosition.fromJson(Map<String, dynamic> json) => HexPosition(
        hexIndex: json['hexIndex'] as int,
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
        rotation: (json['rotation'] as int?) ?? 0,
        edgeRotation: (json['edgeRotation'] as int?) ?? 0,
      );
}
