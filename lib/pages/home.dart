import 'package:flutter/material.dart';
import 'package:handychat/logic.dart';
import 'package:handychat/main.dart';
import 'package:handychat/pages/chat.dart';
import 'package:handychat/pages/settings.dart';

//TODO: ykw? ill probably easily make this thing if i actually watch a tutorial or just read how the state things work and how the app should actually be structured

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
            overflow: TextOverflow.clip,
            "${chat.messages[chat.messages.length - 1].sender.name}: ${chat.messages[chat.messages.length - 1].text}",
            maxLines: 2,
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chat),
          ),
        );
      },
      icon: Image.network(
        chat.picture,
        width: 56,
        height: 56,
        errorBuilder: (context, error, stackTrace) => const Image(
          image: AssetImage("assets/cat.png"),
          width: 56,
          height: 56,
        ),
      ),
    );
  }

  final List<String> channels = [];

  @override
  void initState() {
    channels.addAll(account.channels.keys);
    super.initState();
  }

  @override
  void dispose() {
    channels.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        itemBuilder: (context, index) {
          final Channel? c = account.channels[channels[index]];
          if (c == null) {
            return Container();
          }
          return chat(c);
        },
        itemCount: channels.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: 4,
        ),
      ),
    );
  }
}
