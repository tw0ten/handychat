import 'package:flutter/material.dart';
import 'package:handychat/main/elements/lineinput.dart';
import 'package:handychat/main/elements/pad.dart';
import 'package:handychat/main/elements/util.dart';
import 'package:handychat/main/elements/webimage.dart';
import 'package:handychat/main/logic.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController controller =
      TextEditingController(text: account.user.name);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Widget pad(Widget c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 4),
      child: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text("profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Pad(
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(account.email),
                const SizedBox(
                  height: 4,
                ),
                IconButton(
                  onPressed: () {},
                  icon: WebImage(
                    account.user.picture,
                    width: 64,
                    height: 64,
                  ),
                ),
                pad(
                  LineInput(
                    controller: controller,
                    type: LineInputType.username,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                SelectableText(account.user.id ?? ""),
                const SizedBox(
                  height: 8,
                ),
                TextButton(
                  onPressed: () {
                    account.user.name = controller.text;
                    account.updateProfile();
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
                    if(!await confirm(context, "logout?")) return;
                    await account.logout();
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text(
                    "logout",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
