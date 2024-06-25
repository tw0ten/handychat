import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier()
      : _themeData = createTheme(
            fgc: const Color(0xFFFFFFFF),
            bgc: const Color(0xFF202020),
            acc: const Color(0xFF40E0D0));

  getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}

ThemeData createTheme(
    {required Color fgc, required Color bgc, required Color acc}) {
  return ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: fgc,
        onPrimary: bgc,
        secondary: acc,
        onSecondary: fgc,
        error: Colors.red,
        onError: fgc,
        surface: bgc,
        onSurface: fgc),
    useMaterial3: true,
    fontFamily: "JetBrains Mono",
  );
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text("settings"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("theme"),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(createTheme(
                        fgc: await pickColor("foreground color", context,
                            tn.getTheme().colorScheme.primary),
                        bgc: tn.getTheme().colorScheme.surface,
                        acc: tn.getTheme().colorScheme.secondary));
                  },
                  label: const Text("foreground"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(createTheme(
                        fgc: tn.getTheme().colorScheme.primary,
                        bgc: await pickColor("background color", context,
                            tn.getTheme().colorScheme.surface),
                        acc: tn.getTheme().colorScheme.secondary));
                  },
                  label: const Text("background"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(createTheme(
                        fgc: tn.getTheme().colorScheme.primary,
                        bgc: tn.getTheme().colorScheme.surface,
                        acc: await pickColor("accent color", context,
                            tn.getTheme().colorScheme.secondary)));
                  },
                  label: const Text("accent"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Color> pickColor(
      String title, BuildContext context, Color currentColor) async {
    Color? col = await showDialog<Color>(
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
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('SELECT'),
              onPressed: () => Navigator.of(context).pop(tempColor),
            ),
          ],
        );
      },
    );
    return col ?? currentColor;
  }
}
