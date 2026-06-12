import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/hex_layout.dart';
import '../models/hex_state.dart';
import '../utils/color_channels.dart';
import '../utils/default_layout.dart';
import 'layout_storage_service.dart';
import 'settings_storage_service.dart';
import 'udp_service.dart';

/// Number of hexagons in the HexaGlow build.
const int kHexCount = 7;

/// Central app state: hexagon layout, optimistic colors, connection
/// settings, and the UDP service used to talk to the ESP32.
class HexStateProvider extends ChangeNotifier {
  HexStateProvider({
    LayoutStorageService? layoutStorage,
    SettingsStorageService? settingsStorage,
  })  : _layoutStorage = layoutStorage ?? LayoutStorageService(),
        _settingsStorage = settingsStorage ?? SettingsStorageService();

  final LayoutStorageService _layoutStorage;
  final SettingsStorageService _settingsStorage;

  late UdpService udp;

  bool isLoading = true;
  List<HexPosition> layout = [];
  final List<HexState> hexStates =
      List.generate(kHexCount, (i) => HexState(hexIndex: i + 1));
  AppSettings settings = AppSettings.defaultSettings;
  int brightness = 255;

  Future<void> init() async {
    final savedLayout = await _layoutStorage.loadLayout();
    if (savedLayout != null && savedLayout.length == kHexCount) {
      layout = savedLayout;
    } else {
      layout = defaultLayout();
      await _layoutStorage.saveLayout(layout);
    }

    settings = await _settingsStorage.loadSettings() ?? AppSettings.defaultSettings;
    udp = UdpService(targetIp: settings.esp32Ip, targetPort: settings.port);

    isLoading = false;
    notifyListeners();
  }

  HexState hexStateFor(int hexIndex) => hexStates[hexIndex - 1];

  /// Live-updates a hexagon's position during a drag without touching disk.
  void updateLayoutDelta(int hexIndex, Offset delta) {
    final i = layout.indexWhere((p) => p.hexIndex == hexIndex);
    if (i == -1) return;
    layout[i] = layout[i].copyWith(
      dx: layout[i].dx + delta.dx,
      dy: layout[i].dy + delta.dy,
    );
    notifyListeners();
  }

  /// Persists the current layout, e.g. once a drag gesture ends.
  Future<void> persistLayout() => _layoutStorage.saveLayout(layout);

  Future<void> sendColorAll(Color color) async {
    for (final state in hexStates) {
      state.setWholeColor(color);
    }
    notifyListeners();
    await udp.sendColorAll(color.r8, color.g8, color.b8);
  }

  Future<void> sendColorHex(int hexIndex, Color color) async {
    hexStateFor(hexIndex).setWholeColor(color);
    notifyListeners();
    await udp.sendColorHex(hexIndex, color.r8, color.g8, color.b8);
  }

  Future<void> sendColorEdge(int hexIndex, int edge, Color color) async {
    hexStateFor(hexIndex).setEdgeColor(edge, color);
    notifyListeners();
    await udp.sendColorEdge(hexIndex, edge, color.r8, color.g8, color.b8);
  }

  Future<void> sendColorPixel(int hexIndex, int localIndex, Color color) async {
    final absoluteIndex = (hexIndex - 1) * 18 + localIndex;
    await udp.sendColorPixel(hexIndex, absoluteIndex, color.r8, color.g8, color.b8);
  }

  /// Updates the displayed brightness value without sending UDP traffic,
  /// used while the brightness slider is being dragged.
  void previewBrightness(int value) {
    brightness = value;
    notifyListeners();
  }

  Future<void> sendBrightness(int value) async {
    previewBrightness(value);
    await udp.sendBrightness(value);
  }

  Future<void> sendClear() async {
    for (final state in hexStates) {
      state.clear();
    }
    notifyListeners();
    await udp.sendClear();
  }

  Future<void> updateSettings(String ip, int port) async {
    settings = AppSettings(esp32Ip: ip, port: port);
    udp.updateTarget(ip, port);
    await _settingsStorage.saveSettings(settings);
    notifyListeners();
  }

  @override
  void dispose() {
    udp.dispose();
    super.dispose();
  }
}
