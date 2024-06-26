import 'package:flutter/material.dart';
import 'package:handychat/logic.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.chat, {super.key});
  final Channel chat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scontroller = ScrollController();

  Widget message(Message message) {
    return ListTile(
      leading: Image.network(
        message.sender.picture,
        width: 32,
        height: 32,
      ),
      title: Row(
        children: [
          Text(
            message.sender.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(
            width: 4,
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
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.primary.withAlpha(128),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    scontroller.dispose();
  }

  final List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Image.network(
                widget.chat.picture,
                width: 40,
                height: 40,
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                widget.chat.name,
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
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => message(messages[index]),
              separatorBuilder: (context, index) => const SizedBox(
                height: 4,
              ),
              itemCount: messages.length,
              controller: scontroller,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
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
                    final msg = await account.sendMessage(
                        Message(
                          text: controller.text,
                          sender: account.user,
                          timestamp: DateTime.now(),
                        ),
                        widget.chat);
                    if (msg != null) {
                      controller.clear();
                      setState(() {
                        messages.add(msg);
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scontroller.animateTo(
                          scontroller.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      });
                    } else {
                      scontroller.animateTo(
                        scontroller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
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
