import 'package:flutter/material.dart';
import 'package:handychat/main/elements/lineinput.dart';
import 'package:handychat/main/elements/util.dart';
import 'package:handychat/main/logic.dart';

import '../../elements/pad.dart';
import '../../elements/webimage.dart';
import '../../db.dart';

class _ChatSettings extends StatefulWidget {
  const _ChatSettings(this.id);

  final String id;

  @override
  State<_ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<_ChatSettings> {
  Channel channel() {
    return account.channel(widget.id);
  }

  TextEditingController addUser = TextEditingController();
  final List<Widget> users = [];

  @override
  Widget build(BuildContext context) {
    users
        .addAll(channel().users.values.map((c) => Text(c.name ?? "")).toList());
    TextEditingController name = TextEditingController(
      text: channel().name ?? "",
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: const Text("channel settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Pad(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: WebImage(
                      channel().picture,
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  LineInput(
                    controller: name,
                    hint: "name",
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Column(
                    children: users,
                  ),
                  LineInput(
                    controller: addUser,
                    hint: "new user id",
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton(
                    onPressed: () async {
                      if (addUser.text.isNotEmpty) {
                        final User u = User(id: addUser.text);
                        if (!(await u.fetch()).exists) return;
                        u.addChannel(channel());
                        channel().users.putIfAbsent(addUser.text, () => u);
                      }
                      if (name.text.isNotEmpty) {
                        channel().name = name.text;
                      }
                      account.updateChannel(channel());
                      setState(() {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    },
                    child: Text(
                      "update",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!await confirm(
                          context, "delete \"${channel().name}\"?")) return;
                      await account.deleteChannel(channel());
                      setState(() {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    },
                    child: Text(
                      "delete",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage(this.id, {super.key});

  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scontroller = ScrollController();

  Channel channel() {
    return account.channel(widget.id);
  }

  Widget message(Message message) {
    return ListTile(
      leading: WebImage(
        message.sender.picture,
        width: 32,
        height: 32,
      ),
      title: Row(
        children: [
          Text(
            message.sender.name ?? "loading...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            message.formatTimestamp(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
          ),
        ],
      ),
      subtitle: Text(message.text),
      // trailing: IconButton(
      //   onPressed: () {},
      //   icon: Icon(
      //     Icons.info,
      //     color: Theme.of(context).colorScheme.primary.withAlpha(128),
      //   ),
      // ),
    );
  }

  void scListener() async {
    if (scontroller.position.atEdge &&
        scontroller.position.pixels == scontroller.position.maxScrollExtent) {
      channel().fetchMessages();
    }
  }

  @override
  void initState() {
    super.initState();
    scontroller.addListener(scListener);
  }

  @override
  void dispose() {
    controller.dispose();
    scontroller.removeListener(scListener);
    scontroller.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    scontroller.animateTo(
      scontroller.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            IconButton(
              padding: const EdgeInsets.all(1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _ChatSettings(widget.id),
                  ),
                );
              },
              icon: WebImage(
                channel().picture,
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                channel().name ?? "loading...",
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Pad(
              StreamBuilder(
                stream: channel().stream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "error",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Center(child: Text("loading..."));
                  }

                  return ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) =>
                        message(snapshot.data![index]),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 4,
                    ),
                    reverse: true,
                    itemCount: snapshot.data!.length,
                    controller: scontroller,
                  );
                },
              ),
            ),
          ),
          Pad(
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.attach_file),
                //   onPressed: () {},
                // ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "...",
                          border: InputBorder.none,
                        ),
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final Message msg = Message(
                      text: controller.text,
                      sender: account.user,
                      timestamp: DateTime.now(),
                      attachments: [],
                    );
                    if (msg.validate()) {
                      controller.clear();
                      channel().send(msg);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToBottom();
                      });
                    } else {
                      scrollToBottom();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
