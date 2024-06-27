import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:handychat/logic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
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
      onSurface: fgc,
    ),
    useMaterial3: true,
    fontFamily: "JetBrains Mono",
  );
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController controller =
      TextEditingController(text: account.user.name);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Widget colorIcon(Color c) {
    return Icon(
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
    );
  }

  final divider = const Divider(
    indent: 40,
    endIndent: 40,
    thickness: 1,
    height: 25,
  );

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "user",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {},
              icon: Image.network(
                account.user.picture,
                width: 64,
                height: 64,
              ),
            ),
            SizedBox(
              width: 12.0 * User.maxNameLength,
              child: TextField(
                controller: controller,
                onEditingComplete: () {},
                autocorrect: false,
                enableSuggestions: false,
                maxLength: User.maxNameLength,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            TextButton(
              onPressed: () {
                account.user.name = controller.text;
                account.updateProfile();
              },
              child: Text(
                "update",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            divider,
            const Text(
              "theme",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      ThemeNotifier tn =
                          Provider.of<ThemeNotifier>(context, listen: false);
                      tn.setTheme(
                        fgc: await pickColor(
                            "foreground color", context, tn.fgc),
                      );
                    },
                    label: const Text("foreground"),
                    iconAlignment: IconAlignment.end,
                    icon: colorIcon(Theme.of(context).colorScheme.primary),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      ThemeNotifier tn =
                          Provider.of<ThemeNotifier>(context, listen: false);
                      tn.setTheme(
                        bgc: await pickColor(
                            "background color", context, tn.bgc),
                      );
                    },
                    label: const Text("background"),
                    iconAlignment: IconAlignment.end,
                    icon: colorIcon(Theme.of(context).colorScheme.surface),
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
                    icon: colorIcon(Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                final ThemeNotifier tn =
                    Provider.of<ThemeNotifier>(context, listen: false);
                tn.resetTheme();
                tn.setTheme(fgc: tn.fgc, bgc: tn.bgc, acc: tn.acc);
              },
              child: Text(
                "reset",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            )
          ],
        ),
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
    );
  }
}
