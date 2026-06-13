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

  const HexPosition({
    required this.hexIndex,
    required this.dx,
    required this.dy,
    this.rotation = 0,
  });

  HexPosition copyWith({double? dx, double? dy, int? rotation}) {
    return HexPosition(
      hexIndex: hexIndex,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() => {
        'hexIndex': hexIndex,
        'dx': dx,
        'dy': dy,
        'rotation': rotation,
      };

  factory HexPosition.fromJson(Map<String, dynamic> json) => HexPosition(
        hexIndex: json['hexIndex'] as int,
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
        rotation: (json['rotation'] as int?) ?? 0,
      );
}
