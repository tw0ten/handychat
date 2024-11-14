import 'package:flutter/material.dart';
import 'package:handychat/main/elements/colorselect.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../elements/pad.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text("settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Pad(
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorSelect(
                      Theme.of(context).colorScheme.primary,
                      "foreground",
                      (c) {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme(fgc: c);
                      },
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    ColorSelect(
                      Theme.of(context).colorScheme.surface,
                      "background",
                      (c) {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme(bgc: c);
                      },
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    ColorSelect(
                      Theme.of(context).colorScheme.secondary,
                      "accent",
                      (c) {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme(acc: c);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              TextButton(
                onPressed: () {
                  final ThemeNotifier tn =
                      Provider.of<ThemeNotifier>(context, listen: false);
                  tn.resetTheme();
                  tn.setTheme(fgc: tn.fgc, bgc: tn.bgc, acc: tn.acc);
                },
                child: Text(
                  "reset theme",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  late Color fgc, bgc, acc;
  ThemeData? _themeData;

  ThemeNotifier() {
    resetTheme();
  }

  void resetTheme() {
    fgc = const Color(0xFFFFFFFF);
    bgc = const Color(0xFF202020);
    acc = const Color(0xFF40E0D0);
  }

  ThemeData getTheme() {
    if (_themeData == null) {
      setTheme();
      return _createTheme(fgc: fgc, bgc: bgc, acc: acc);
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

    _themeData = _createTheme(fgc: fgc, bgc: bgc, acc: acc);
    notifyListeners();
  }
}

ThemeData _createTheme(
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
      onSurface: fgc,
    ),
    useMaterial3: true,
    fontFamily: "JetBrains Mono",
  );
}
