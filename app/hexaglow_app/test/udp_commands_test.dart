import 'package:flutter_test/flutter_test.dart';
import 'package:hexaglow_app/services/udp_commands.dart';

void main() {
  group('UdpCommands', () {
    test('clear', () {
      expect(UdpCommands.clear(), 'CLEAR');
    });

    test('colorAll', () {
      expect(UdpCommands.colorAll(255, 0, 128), 'COLORALL 255 0 128');
    });

    test('colorHex', () {
      expect(UdpCommands.colorHex(3, 10, 20, 30), 'COLORHEX 3 10 20 30');
    });

    test('colorEdge', () {
      expect(UdpCommands.colorEdge(2, 5, 1, 2, 3), 'COLOREDGE 2 5 1 2 3');
    });

    test('colorPixel', () {
      expect(UdpCommands.colorPixel(1, 17, 255, 255, 255), 'COLORPIXEL 1 17 255 255 255');
    });

    test('brightness', () {
      expect(UdpCommands.brightness(128), 'BRIGHTNESS 128');
    });
  });
}
