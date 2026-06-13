import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hex_state_provider.dart';
import '../utils/default_layout.dart';
import '../widgets/color_wheel_dialog.dart';
import '../widgets/hexagon_widget.dart';
import 'hex_detail_screen.dart';
import 'presets_screen.dart';
import 'settings_screen.dart';

/// Main screen: a freely-arrangeable canvas of the 7 hexagons plus global
/// controls (color all, brightness, clear).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HexStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HexaGlow'),
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.lock_open : Icons.lock_outline),
            tooltip: _editMode ? 'Done arranging' : 'Edit layout',
            onPressed: () => setState(() => _editMode = !_editMode),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Color Presets',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresetsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_editMode)
            Container(
              width: double.infinity,
              color: Colors.amber.shade800,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Drag hexagons to match your physical layout. Tap "Done arranging" when finished.',
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: _buildCanvas(context, provider)),
          _buildControls(context, provider),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, HexStateProvider provider) {
    return InteractiveViewer(
      constrained: false,
      panEnabled: !_editMode,
      scaleEnabled: !_editMode,
      minScale: 0.3,
      maxScale: 3,
      child: SizedBox(
        width: kCanvasSize,
        height: kCanvasSize,
        child: Stack(
          children: [
            for (final pos in provider.layout)
              Positioned(
                left: pos.dx,
                top: pos.dy,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onPanUpdate: _editMode
                          ? (details) => provider.updateLayoutDelta(pos.hexIndex, details.delta)
                          : null,
                      onPanEnd: _editMode ? (_) => provider.persistLayout() : null,
                      onTap: _editMode
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HexDetailScreen(hexIndex: pos.hexIndex),
                                ),
                              ),
                      child: HexagonWidget(
                        state: provider.hexStateFor(pos.hexIndex),
                        size: kHexBoxSize,
                        rotation: pos.rotation,
                        edgeRotation: pos.edgeRotation,
                        showEdgeLabels: _editMode,
                      ),
                    ),
                    if (_editMode)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.rotate_right, size: 18, color: Colors.white),
                            tooltip: 'Rotate',
                            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                            padding: EdgeInsets.zero,
                            onPressed: () => provider.rotateHex(pos.hexIndex),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, HexStateProvider provider) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_6),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: provider.brightness.toDouble(),
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: provider.brightness.toString(),
                    onChanged: (value) => provider.previewBrightness(value.round()),
                    onChangeEnd: (value) => provider.sendBrightness(value.round()),
                  ),
                ),
                SizedBox(width: 36, child: Text('${provider.brightness}')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.palette),
                    label: const Text('Color All'),
                    onPressed: () async {
                      final color = await showColorWheelDialog(
                        context,
                        initialColor: provider.hexStateFor(1).wholeColor,
                        title: 'Color all hexagons',
                      );
                      if (color != null) {
                        await provider.sendColorAll(color);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    onPressed: () => provider.sendClear(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
