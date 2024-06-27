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
        errorBuilder: (context, error, stackTrace) => const Image(
          image: AssetImage("assets/cat.png"),
          width: 32,
          height: 32,
        ),
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
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.primary.withAlpha(128),
        ),
      ),
    );
  }

  void scListener() async {
    if (scontroller.position.atEdge &&
        scontroller.position.pixels == scontroller.position.maxScrollExtent) {
      fetchOldMessages();
    }
  }

  void fetchOldMessages() async {
    final List<Message> msgs =
        await account.fetchMessages(widget.chat, 10) ?? [];
    widget.chat.messages.addAll(msgs);
    account.channels.update(widget.chat.id, (c) {
      c.lastMessage = widget.chat.lastMessage;
      c.messages = widget.chat.messages;
      return c;
    });
    setState(() {
      messages.addAll(msgs);
    });
  }

  @override
  void initState() {
    super.initState();
    scontroller.addListener(scListener);
    messages.addAll(widget.chat.messages);
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

  final List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    if (widget.chat.messages.length == 1) {
      fetchOldMessages();
    }

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
                errorBuilder: (context, error, stackTrace) => const Image(
                  image: AssetImage("assets/cat.png"),
                  width: 40,
                  height: 40,
                ),
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
              reverse: true,
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
                          attachments: [],
                        ),
                        widget.chat);
                    if (msg != null) {
                      controller.clear();
                      widget.chat.messages.insert(0, msg);
                      account.channels.update(widget.chat.id, (c) {
                        c.messages = widget.chat.messages;
                        return c;
                      });
                      setState(() {
                        messages.insert(0, msg);
                      });
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
