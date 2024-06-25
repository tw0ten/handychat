import 'dart:math';

import 'package:flutter/material.dart';
import 'package:handychat/logic.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.chat, {super.key});
  final Chat chat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Color randomColor([int seed = 0]) {
  final r = Random(seed);
  return Color(0xFF000000 + r.nextInt(0x00FFFFFF));
}

class _ChatPageState extends State<ChatPage> {
  Widget message(Message message) {
    return Text(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image(
              image: widget.chat.icon,
              width: 40,
              height: 40,
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
              reverse: true,
              itemBuilder: (context, index) => message(Message(id: index)),
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
                        onSubmitted: (value) {},
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
