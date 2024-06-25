import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

//theres probly a way to do this more compact - use reset direct in constructor or smthh but NOT IMPORTANT RN. PLEASE

const Color defFgc = Color(0xFFFFFFFF);
const Color defBgc = Color(0xFF202020);
const Color defAcc = Color(0xFF40E0D0);

class ThemeNotifier extends ChangeNotifier {
  Color fgc, bgc, acc;
  ThemeData? _themeData;

  ThemeNotifier()
      : acc = defAcc,
        bgc = defBgc,
        fgc = defFgc;

  ThemeData getTheme() {
    if (_themeData == null) {
      setTheme();
      return createTheme(fgc: fgc, bgc: bgc, acc: acc);
    }
    return _themeData!;
  }

  void setTheme({Color? fgc, Color? bgc, Color? acc}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (fgc != null) {
      prefs.setInt("fgc", fgc.value);
    } else {
      fgc = Color(prefs.getInt("fgc") ?? this.fgc.value);
    }
    this.fgc = fgc;
    if (bgc != null) {
      prefs.setInt("bgc", bgc.value);
    } else {
      bgc = Color(prefs.getInt("bgc") ?? this.bgc.value);
    }
    this.bgc = bgc;
    if (acc != null) {
      prefs.setInt("acc", acc.value);
    } else {
      acc = Color(prefs.getInt("acc") ?? this.acc.value);
    }
    this.acc = acc;

    _themeData = createTheme(fgc: fgc, bgc: bgc, acc: acc);
    notifyListeners();
  }
}

ThemeData createTheme(
    {required Color fgc, required Color bgc, required Color acc}) {
  return ThemeData(
    colorScheme: ColorScheme(
        brightness:
            bgc.computeLuminance() < 0.5 ? Brightness.dark : Brightness.light,
        primary: fgc,
        onPrimary: bgc,
        secondary: acc,
        onSecondary: fgc,
        error: const Color(0xFFFF0000),
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
          const Text("theme", style: TextStyle(fontWeight: FontWeight.bold),),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(
                      fgc: await pickColor("foreground color", context, tn.fgc),
                    );
                  },
                  label: const Text("foreground"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.primary,
                    shadows: [
                      BoxShadow(
                          color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .computeLuminance() <
                                  0.5
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF000000),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: const Offset(0, 0)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(
                      bgc: await pickColor("background color", context, tn.bgc),
                    );
                  },
                  label: const Text("background"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.surface,
                    shadows: [
                      BoxShadow(
                          color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .computeLuminance() <
                                  0.5
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF000000),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: const Offset(0, 0)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    ThemeNotifier tn =
                        Provider.of<ThemeNotifier>(context, listen: false);
                    tn.setTheme(
                      acc: await pickColor("accent color", context, tn.acc),
                    );
                  },
                  label: const Text("accent"),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    Icons.circle,
                    color: Theme.of(context).colorScheme.secondary,
                    shadows: [
                      BoxShadow(
                          color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .computeLuminance() <
                                  0.5
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF000000),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: const Offset(0, 0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme(fgc: defFgc, bgc: defBgc, acc: defAcc);
              },
              child: const Text("reset"))
        ],
      ),
    );
  }

  Future<Color?> pickColor(
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
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(
                'SELECT',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () => Navigator.of(context).pop(tempColor),
            ),
          ],
        );
      },
    );
  }
}
