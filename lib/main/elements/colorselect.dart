import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSelect extends StatelessWidget {
  const ColorSelect(this.c, this.label, this.f, {super.key});

  final Color c;
  final String label;
  final void Function(Color c) f;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        f(await pickColor("$label color", context, c));
      },
      label: Text(label),
      iconAlignment: IconAlignment.end,
      icon: Icon(
        Icons.circle,
        color: c,
        shadows: [
          BoxShadow(
            color: c.computeLuminance() < 0.5
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF000000),
            spreadRadius: 0,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
}

Future<Color> pickColor(
    String title, BuildContext context, Color currentColor) async {
  return await showDialog<Color>(
        context: context,
        builder: (context) {
          Color tempColor = currentColor;
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (color) => tempColor = color,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(
                  "SELECT",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () => Navigator.of(context).pop(tempColor),
              ),
            ],
          );
        },
      ) ??
      currentColor;
}
