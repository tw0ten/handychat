import 'package:flutter/material.dart';
import 'package:handychat/main/elements/lineinput.dart';
import 'package:handychat/main/logic.dart';
import 'package:handychat/main/pages/home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            account.postLogin();
            return const HomePage();
          }
          return const _AuthPage();
        },
      ),
    );
  }
}

class _AuthPage extends StatefulWidget {
  const _AuthPage();

  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  bool page = true;

  void toggle() {
    setState(() {
      page = !page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (page) {
      return _LoginPage(toggle);
    }
    return _RegisterPage(toggle);
  }
}

class _LoginPage extends StatelessWidget {
  _LoginPage(this.f);
  final void Function() f;
  final TextEditingController email = TextEditingController(),
      pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 120,
              vertical: 4,
            ),
            child: Column(
              children: [
                LineInput(
                  type: LineInputType.email,
                  controller: email,
                ),
                const SizedBox(
                  height: 4,
                ),
                LineInput(
                  type: LineInputType.password,
                  controller: pwd,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  try {
                    await account.login(email.text, pwd.text);
                  } catch (e) {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(e.toString()),
                      ),
                    );
                  }
                },
                child: Text(
                  "login",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              TextButton(
                onPressed: f,
                child: const Text(
                  "register",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPage extends StatelessWidget {
  _RegisterPage(this.f);
  final void Function() f;
  final TextEditingController uname = TextEditingController(),
      email = TextEditingController(),
      pwd = TextEditingController(),
      pwdc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 120,
              vertical: 4,
            ),
            child: Column(
              children: [
                LineInput(
                  type: LineInputType.username,
                  controller: uname,
                ),
                const SizedBox(
                  height: 4,
                ),
                LineInput(
                  type: LineInputType.email,
                  controller: email,
                ),
                const SizedBox(
                  height: 4,
                ),
                LineInput(
                  type: LineInputType.password,
                  controller: pwd,
                ),
                const SizedBox(
                  height: 4,
                ),
                LineInput(
                  type: LineInputType.password,
                  controller: pwdc,
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: f,
                child: const Text(
                  "login",
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (pwd.text != pwdc.text) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text("passwords do not match"),
                      ),
                    );
                    return;
                  }
                  try {
                    await account.register(uname.text, email.text, pwd.text);
                  } catch (e) {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(e.toString()),
                      ),
                    );
                  }
                },
                child: Text(
                  "register",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
