import 'package:flutter/material.dart';
import 'package:handychat/pages/settings.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

const String title = "HANDYCHAT";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title,
          theme: themeNotifier.getTheme(),
          home: const HomePage(),
        );
      },
    );
  }
}
