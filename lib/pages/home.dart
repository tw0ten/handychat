import 'package:flutter/material.dart';
import 'package:handychat/logic.dart';
import 'package:handychat/main.dart';
import 'package:handychat/pages/chat.dart';
import 'package:handychat/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final divider = const Divider(
    indent: 0,
    endIndent: 0,
    thickness: 1,
    height: 5,
  );

  Widget chat(Channel chat) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerLeft,
        fixedSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      label: Text(chat.name),
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chat),
          ),
        )
      },
      icon: Image.network(
        chat.picture,
        width: 60,
        height: 60,
      ),
      iconAlignment: IconAlignment.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    )
                  },
              icon: const Icon(Icons.settings)),
          const SizedBox(
            width: 4,
          )
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => chat(account.channels[index]),
        separatorBuilder: (context, index) => divider,
        itemCount: account.channels.length,
      ),
    );
  }
}
