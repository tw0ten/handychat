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

  void scrollBottom() {
    scontroller.animateTo(
      scontroller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Widget message(Message message) {
    return Text(message.text);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    scontroller.dispose();
  }

  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              widget.chat.picture,
              width: 40,
              height: 40,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(
              width: 9,
            ),
            Text(widget.chat.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => message(messages[index]),
              itemCount: messages.length,
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
                      controller: scontroller,
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
                    scrollBottom();
                    final String msg = controller.text;
                    // mess. probablywill have better callback update shit system when the db works, for now im guessing it freezes everything depeding on internet speed? maybe not thoug
                    setState(() {
                      controller.clear();
                    });
                    final msg1 = await account.sendMessage(msg, widget.chat);
                    setState(() {
                      messages.add(msg1);
                    });
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
