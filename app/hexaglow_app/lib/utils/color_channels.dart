import 'package:flutter/material.dart';

/// Convenience accessors for a [Color]'s 0-255 integer RGB channels,
/// matching the integer ranges expected by the firmware's UDP commands.
extension ColorChannels on Color {
  int get r8 => (r * 255.0).round().clamp(0, 255);
  int get g8 => (g * 255.0).round().clamp(0, 255);
  int get b8 => (b * 255.0).round().clamp(0, 255);
}
