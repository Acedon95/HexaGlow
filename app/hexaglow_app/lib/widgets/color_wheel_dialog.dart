import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Shows a color-wheel picker dialog and returns the chosen color, or `null`
/// if the user cancels.
Future<Color?> showColorWheelDialog(
  BuildContext context, {
  Color initialColor = Colors.white,
  String title = 'Pick a color',
}) {
  Color picked = initialColor;
  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: (color) => picked = color,
          colorPickerWidth: 300,
          pickerAreaHeightPercent: 0.7,
          enableAlpha: false,
          displayThumbColor: true,
          paletteType: PaletteType.hsvWithHue,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, picked),
          child: const Text('Apply'),
        ),
      ],
    ),
  );
}
