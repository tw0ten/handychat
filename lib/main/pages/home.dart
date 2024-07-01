import 'package:flutter/material.dart';
import 'package:handychat/main/elements/util.dart';
import 'package:handychat/main/elements/webimage.dart';
import 'package:handychat/main.dart';
import 'package:handychat/main/logic.dart';
import 'package:handychat/main/pages/channel/chat.dart';
import 'package:handychat/main/pages/etc/profile.dart';
import 'package:handychat/main/pages/etc/settings.dart';

import '../elements/pad.dart';
import '../db.dart';

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
            chat.name ?? "loading...",
            maxLines: 1,
            // style: TextStyle(
            //   color: Theme.of(context).colorScheme.secondary,
            // ),
          ),
          Text(
            chat.messages.isNotEmpty
                ? "${chat.messages.first.sender.name ?? "loading..."}: ${chat.messages.first.text}${chat.messages.first.attachments.isNotEmpty ? " [files attached]" : ""}"
                : "[no messages]",
            softWrap: true,
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chat.id!),
          ),
        );
      },
      icon: WebImage(
        chat.picture,
        width: 56,
        height: 56,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        titleSpacing: 8,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              if (!await confirm(context, "create a new channel?")) return;
              await account.createChannel();
            },
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
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              )
            },
            icon: const Icon(Icons.account_box),
          ),
          const SizedBox(
            width: 4,
          ),
        ],
      ),
      body: Pad(
        StreamBuilder(
          stream: account.channels(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                "error",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ));
            }
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const Center(child: Text("loading..."));
            }

            return ListView.separated(
              itemBuilder: (context, index) {
                return chat(snapshot.data![index]);
              },
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: 4,
              ),
            );
          },
        ),
      ),
    );
  }
}
