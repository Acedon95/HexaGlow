import 'dart:convert';
import 'dart:io';

import 'udp_commands.dart';

/// Sends fire-and-forget UDP command packets to the HexaGlow ESP32.
///
/// The ESP32 has no acknowledgement protocol, so sends are best-effort:
/// failures (e.g. unreachable host) are swallowed rather than surfaced,
/// matching the optimistic-UI design of the rest of the app.
class UdpService {
  UdpService({required this.targetIp, required this.targetPort});

  String targetIp;
  int targetPort;

  RawDatagramSocket? _socket;

  Future<void> _ensureSocket() async {
    _socket ??= await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  }

  Future<void> _send(String command) async {
    try {
      await _ensureSocket();
      _socket!.send(utf8.encode(command), InternetAddress(targetIp), targetPort);
    } catch (_) {
      // Best-effort UDP send; ignore unreachable host / socket errors.
    }
  }

  Future<void> sendClear() => _send(UdpCommands.clear());

  Future<void> sendColorAll(int r, int g, int b) => _send(UdpCommands.colorAll(r, g, b));

  Future<void> sendColorHex(int hexIndex, int r, int g, int b) =>
      _send(UdpCommands.colorHex(hexIndex, r, g, b));

  Future<void> sendColorEdge(int hexIndex, int edge, int r, int g, int b) =>
      _send(UdpCommands.colorEdge(hexIndex, edge, r, g, b));

  Future<void> sendColorPixel(int hexIndex, int index, int r, int g, int b) =>
      _send(UdpCommands.colorPixel(hexIndex, index, r, g, b));

  Future<void> sendBrightness(int value) => _send(UdpCommands.brightness(value));

  void updateTarget(String ip, int port) {
    targetIp = ip;
    targetPort = port;
  }

  void dispose() {
    _socket?.close();
    _socket = null;
  }
}
