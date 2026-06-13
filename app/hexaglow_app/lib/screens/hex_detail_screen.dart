import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hex_state_provider.dart';
import '../widgets/color_wheel_dialog.dart';
import '../widgets/hexagon_widget.dart';

/// Per-hexagon controls: set the whole hexagon's color, set each of its 6
/// edges individually, or (optionally) set individual pixels.
class HexDetailScreen extends StatefulWidget {
  const HexDetailScreen({super.key, required this.hexIndex});

  final int hexIndex;

  @override
  State<HexDetailScreen> createState() => _HexDetailScreenState();
}

class _HexDetailScreenState extends State<HexDetailScreen> {
  /// Local-only optimistic colors for the 18 pixels of this hexagon.
  /// Not part of [HexState] since per-pixel control is a secondary feature.
  late List<Color> _pixelColors;

  static const int _pixelsPerHex = 18;

  @override
  void initState() {
    super.initState();
    _pixelColors = List.generate(_pixelsPerHex, (_) => Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HexStateProvider>();
    final state = provider.hexStateFor(widget.hexIndex);
    final rotation = provider.rotationFor(widget.hexIndex);
    final edgeRotation = provider.edgeRotationFor(widget.hexIndex);

    return Scaffold(
      appBar: AppBar(title: Text('Hexagon ${widget.hexIndex}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: HexagonWidget(
              state: state,
              size: 180,
              selected: true,
              rotation: rotation,
              edgeRotation: edgeRotation,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.rotate_right),
              label: Text('Rotate edges (${edgeRotation * 60}°)'),
              onPressed: () => provider.rotateEdges(widget.hexIndex),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.palette),
            label: const Text('Set whole hexagon color'),
            onPressed: () async {
              final color = await showColorWheelDialog(
                context,
                initialColor: state.wholeColor,
                title: 'Hexagon ${widget.hexIndex} color',
              );
              if (color != null) {
                await provider.sendColorHex(widget.hexIndex, color);
                setState(() {
                  for (var i = 0; i < _pixelColors.length; i++) {
                    _pixelColors[i] = color;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Edges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var visualSlot = 0; visualSlot < 6; visualSlot++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      state.edgeColors[provider.firmwareEdge(widget.hexIndex, visualSlot)],
                ),
                title: Text('Edge $visualSlot'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final firmwareEdge = provider.firmwareEdge(widget.hexIndex, visualSlot);
                  final color = await showColorWheelDialog(
                    context,
                    initialColor: state.edgeColors[firmwareEdge],
                    title: 'Hexagon ${widget.hexIndex}, edge $visualSlot',
                  );
                  if (color != null) {
                    await provider.sendColorEdge(widget.hexIndex, firmwareEdge, color);
                    setState(() {
                      for (var p = firmwareEdge * 3; p < firmwareEdge * 3 + 3; p++) {
                        _pixelColors[p] = color;
                      }
                    });
                  }
                },
              ),
            ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('Individual pixels (advanced)'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _pixelsPerHex; i++)
                      GestureDetector(
                        onTap: () async {
                          final color = await showColorWheelDialog(
                            context,
                            initialColor: _pixelColors[i],
                            title: 'Hexagon ${widget.hexIndex}, pixel $i',
                          );
                          if (color != null) {
                            await provider.sendColorPixel(widget.hexIndex, i, color);
                            setState(() => _pixelColors[i] = color);
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _pixelColors[i],
                            border: Border.all(color: Colors.grey.shade600),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$i',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
