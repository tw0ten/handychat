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
  Widget chat(Channel chat) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerLeft,
        fixedSize: const Size.fromHeight(64),
        padding: const EdgeInsets.all(4),
      ),
      label: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            softWrap: false,
            overflow: TextOverflow.fade,
            chat.name,
            maxLines: 1,
          ),
          Text(
            softWrap: true,
            overflow: TextOverflow.fade,
            "${chat.messages[chat.messages.length-1].sender.name}: ${chat.messages[chat.messages.length - 1].text}",
            maxLines: 2,
          ),
        ],
      ),
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: false,
            builder: (context) => ChatPage(chat),
          ),
        )
      },
      icon: Image.network(
        chat.picture,
        width: 56,
        height: 56,
      ),
    );
  }

  final List<Channel> channels = [];

  @override
  Widget build(BuildContext context) {
    channels.clear();
    channels.addAll(account.channels);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
            ),
          ),
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  maintainState: false,
                  builder: (context) => const SettingsPage(),
                ),
              )
            },
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(
            width: 4,
          )
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => chat(channels[index]),
        itemCount: channels.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: 4,
        ),
      ),
    );
  }
}
