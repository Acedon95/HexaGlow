import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/color_preset.dart';
import '../models/hex_layout.dart';
import '../models/hex_state.dart';
import '../utils/color_channels.dart';
import '../utils/default_layout.dart';
import 'layout_storage_service.dart';
import 'preset_storage_service.dart';
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
    PresetStorageService? presetStorage,
  })  : _layoutStorage = layoutStorage ?? LayoutStorageService(),
        _settingsStorage = settingsStorage ?? SettingsStorageService(),
        _presetStorage = presetStorage ?? PresetStorageService();

  final LayoutStorageService _layoutStorage;
  final SettingsStorageService _settingsStorage;
  final PresetStorageService _presetStorage;

  late UdpService udp;

  bool isLoading = true;
  List<HexPosition> layout = [];
  final List<HexState> hexStates =
      List.generate(kHexCount, (i) => HexState(hexIndex: i + 1));
  AppSettings settings = AppSettings.defaultSettings;
  int brightness = 255;
  List<ColorPreset> presets = [];
  bool isApplyingPreset = false;

  /// Delay between UDP commands sent while applying a preset. Each command
  /// triggers a `strip->show()` on the ESP32 (~126 pixels); sending faster
  /// than this overflows its UDP receive buffer and drops packets, so only
  /// some hexagons/edges would update.
  static const _presetCommandDelay = Duration(milliseconds: 30);

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
    presets = await _presetStorage.loadPresets();

    isLoading = false;
    notifyListeners();
  }

  HexState hexStateFor(int hexIndex) => hexStates[hexIndex - 1];

  /// Number of 30-degree clockwise visual rotation steps applied to
  /// [hexIndex]'s hexagon graphic, see [HexPosition.rotation].
  int rotationFor(int hexIndex) =>
      layout.firstWhere((p) => p.hexIndex == hexIndex).rotation;

  /// Rotates [hexIndex] by one more 30-degree step (wrapping 0-11) and persists it.
  Future<void> rotateHex(int hexIndex) async {
    final i = layout.indexWhere((p) => p.hexIndex == hexIndex);
    if (i == -1) return;
    layout[i] = layout[i].copyWith(rotation: (layout[i].rotation + 1) % 12);
    notifyListeners();
    await persistLayout();
  }

  /// Number of 60-degree clockwise steps applied to [hexIndex]'s edge
  /// indices, see [HexPosition.edgeRotation].
  int edgeRotationFor(int hexIndex) =>
      layout.firstWhere((p) => p.hexIndex == hexIndex).edgeRotation;

  /// Maps a fixed on-screen edge slot (0 = top-right, going clockwise,
  /// before [rotationFor] is applied) to the firmware edge index for
  /// [hexIndex], taking its [edgeRotationFor] into account.
  int firmwareEdge(int hexIndex, int visualSlot) =>
      (visualSlot + edgeRotationFor(hexIndex)) % 6;

  /// Rotates [hexIndex]'s edge mapping by one more 60-degree step (wrapping
  /// 0-5) and persists it.
  Future<void> rotateEdges(int hexIndex) async {
    final i = layout.indexWhere((p) => p.hexIndex == hexIndex);
    if (i == -1) return;
    layout[i] = layout[i].copyWith(edgeRotation: (layout[i].edgeRotation + 1) % 6);
    notifyListeners();
    await persistLayout();
  }

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
      state.setAllEdgeColors(color);
    }
    notifyListeners();
    await udp.sendColorAll(color.r8, color.g8, color.b8);
  }

  Future<void> sendColorHex(int hexIndex, Color color) async {
    hexStateFor(hexIndex).setAllEdgeColors(color);
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

  /// Saves the current colors of all 7 hexagons and the global brightness
  /// as a named preset, replacing any existing preset with the same name.
  Future<void> saveCurrentAsPreset(String name) async {
    final preset = ColorPreset(
      name: name,
      wholeColors: hexStates.map((s) => s.wholeColor).toList(),
      edgeColors: hexStates.map((s) => List<Color>.from(s.edgeColors)).toList(),
      brightness: brightness,
    );
    presets = [...presets.where((p) => p.name != name), preset];
    await _presetStorage.savePresets(presets);
    notifyListeners();
  }

  /// Restores all 7 hexagons' colors and the global brightness from [preset].
  ///
  /// While a preset is being applied, further calls are ignored (e.g. if the
  /// user spams the load button) so overlapping UDP bursts can't interleave
  /// and leave some hexagons only partially updated.
  Future<void> applyPreset(ColorPreset preset) async {
    if (isApplyingPreset) return;
    isApplyingPreset = true;

    for (var i = 0; i < kHexCount; i++) {
      final state = hexStateFor(i + 1);
      state.wholeColor = preset.wholeColors[i];
      for (var e = 0; e < 6; e++) {
        state.edgeColors[e] = preset.edgeColors[i][e];
      }
    }
    brightness = preset.brightness;
    notifyListeners();

    try {
      for (var i = 0; i < kHexCount; i++) {
        final hexIndex = i + 1;
        final edges = preset.edgeColors[i];
        for (var e = 0; e < 6; e++) {
          await udp.sendColorEdge(hexIndex, e, edges[e].r8, edges[e].g8, edges[e].b8);
          await Future.delayed(_presetCommandDelay);
        }
      }
      await udp.sendBrightness(brightness);
    } finally {
      isApplyingPreset = false;
      notifyListeners();
    }
  }

  Future<void> deletePreset(String name) async {
    presets = presets.where((p) => p.name != name).toList();
    await _presetStorage.savePresets(presets);
    notifyListeners();
  }

  @override
  void dispose() {
    udp.dispose();
    super.dispose();
  }
}
