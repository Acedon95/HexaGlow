/// Position of a single hexagon on the freely-arrangeable canvas.
///
/// [hexIndex] is the 1-based index used throughout the app and matches the
/// firmware's `hex_index` convention (1-7), so it never needs adjusting
/// before being sent over UDP.
class HexPosition {
  final int hexIndex;
  final double dx;
  final double dy;

  const HexPosition({required this.hexIndex, required this.dx, required this.dy});

  HexPosition copyWith({double? dx, double? dy}) {
    return HexPosition(
      hexIndex: hexIndex,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }

  Map<String, dynamic> toJson() => {
        'hexIndex': hexIndex,
        'dx': dx,
        'dy': dy,
      };

  factory HexPosition.fromJson(Map<String, dynamic> json) => HexPosition(
        hexIndex: json['hexIndex'] as int,
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
      );
}
