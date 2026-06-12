/// Builds the plain-text UDP command strings understood by
/// `EventHandler::create_event_from_string` on the ESP32.
///
/// Kept as pure functions (no socket I/O) so the protocol formatting can be
/// unit tested without a network connection.
class UdpCommands {
  static String clear() => 'CLEAR';

  static String colorAll(int r, int g, int b) => 'COLORALL $r $g $b';

  static String colorHex(int hexIndex, int r, int g, int b) => 'COLORHEX $hexIndex $r $g $b';

  static String colorEdge(int hexIndex, int edge, int r, int g, int b) =>
      'COLOREDGE $hexIndex $edge $r $g $b';

  static String colorPixel(int hexIndex, int index, int r, int g, int b) =>
      'COLORPIXEL $hexIndex $index $r $g $b';

  static String brightness(int value) => 'BRIGHTNESS $value';
}
