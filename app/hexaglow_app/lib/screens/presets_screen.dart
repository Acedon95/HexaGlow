import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hex_state_provider.dart';

/// Lists saved color presets, lets the user load or delete them, and save
/// the current hexagon colors + brightness as a new named preset.
class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HexStateProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Color Presets')),
      body: Column(
        children: [
          if (provider.isApplyingPreset) const LinearProgressIndicator(),
          Expanded(child: _buildList(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text('Save current'),
        onPressed: () => _saveCurrent(context, provider),
      ),
    );
  }

  Widget _buildList(BuildContext context, HexStateProvider provider) {
    return provider.presets.isEmpty
          ? const Center(child: Text('No presets saved yet.'))
          : ListView.builder(
              itemCount: provider.presets.length,
              itemBuilder: (context, index) {
                final preset = provider.presets[index];
                return ListTile(
                  title: Text(preset.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Load',
                        onPressed: provider.isApplyingPreset
                            ? null
                            : () => provider.applyPreset(preset),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: provider.isApplyingPreset
                            ? null
                            : () => _confirmDelete(context, provider, preset.name),
                      ),
                    ],
                  ),
                );
              },
            );
  }

  Future<void> _saveCurrent(BuildContext context, HexStateProvider provider) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save preset'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Preset name'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await provider.saveCurrentAsPreset(name);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HexStateProvider provider,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete preset'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deletePreset(name);
    }
  }
}
