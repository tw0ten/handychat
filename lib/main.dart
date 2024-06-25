import 'package:flutter/material.dart';
import 'package:handychat/pages/settings.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreInstance = FirebaseFirestore.instance;

void sendMessage(String message) {
  firestoreInstance.collection("messages").add({'text': message});
}

void listenForMessages() {
  firestoreInstance.collection("channels").snapshots().listen((snapshot) {
    for (var doc in snapshot.docs) {
      print('Message: ${doc.data()}');
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  listenForMessages();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

const title = "HANDYCHAT";

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
