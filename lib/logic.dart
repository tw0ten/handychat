import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

final Account account = Account(id: "0");

abstract class FSDocument {
  String id;

  CollectionReference getCol();
  DocumentReference getDoc() {
    return getCol().doc(id);
  }

  FSDocument({this.id = ""});
}

class Channel extends FSDocument {
  String name, picture;
  List<User> users = [account.user];
  List<Message> messages = [];

  Channel({
    super.id,
    this.name = "-",
    this.picture =
        "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png",
  });

  @override
  CollectionReference<Object?> getCol() {
    return firestore.collection("channels");
  }
}

class User extends FSDocument {
  static int maxNameLength = 16;
  String name, picture;

  User({
    super.id,
    this.name = "-",
    this.picture = "https://tw0ten.github.io/resources/assets/image/me64.png",
  });

  @override
  CollectionReference<Object?> getCol({FSDocument? parent}) {
    return firestore.collection("users");
  }
}

class Message extends FSDocument {
  String text;
  User sender;
  DateTime timestamp;
  List<String> attachments = [];

  String formatTimestamp() {
    DateTime ts = timestamp.toLocal();
    return "${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}|${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}";
  }

  Message({
    super.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  @override
  CollectionReference<Object?> getCol({FSDocument? parent}) {
    return parent!.getDoc().collection("messages");
  }
}

class Account {
  User user;
  final List<Channel> channels = [];

  Account({required String id}) : user = User(id: id);

  Future<void> login() async {
    user = await fetchUser(user) ?? user;
    var ch = (await user
            .getDoc()
            .get(const GetOptions(source: Source.serverAndCache)))
        .get("channels");
    channels.clear();
    for (DocumentReference doc in ch) {
      final Channel c = Channel(id: doc.id);
      channels.add(await fetchChannel(c) ?? c);
    }
  }

  void updateProfile() {
    user.getDoc().set(
      {
        "name": user.name,
        "picture": user.picture,
      },
    );
  }

  Future<User?> fetchUser(User user) async {
    DocumentSnapshot ss = await user
        .getDoc()
        .get(const GetOptions(source: Source.serverAndCache));
    user.name = ss.get("name");
    user.picture = ss.get("picture");
    return user;
  }

  Future<Channel?> fetchChannel(Channel channel) async {
    DocumentSnapshot ss = await channel
        .getDoc()
        .get(const GetOptions(source: Source.serverAndCache));
    channel.name = ss.get("name");
    channel.picture = ss.get("picture");
    List<User> users = [];
    for (var i in ss.get("users")) {
      final User u = User(id: i.id);
      users.add(await fetchUser(u) ?? u);
    }
    channel.users = users;
    List<Message> messages = [];
    // for (var i in ss.get("messages")) {
    //   // message i guess handle it very unloaded?
    //   // ill need to i mean
    //   // display nonloaded messages
    //   final Message m = Message(
    //     id: i.id,
    //     text: "-",
    //     sender: user,
    //     timestamp: DateTime.now(),
    //   );
    //   messages.add(await fetchMessage(m) ?? m);
    // }
    channel.messages = messages;
    return channel;
  }

  Future<Channel> create(Channel channel) async {
    DocumentReference doc = await channel.getCol().add({
      "name": channel.name,
      "picture": channel.name,
      "users": [user.getDoc()],
    });
    await user.getDoc().update({
      "channels": channel.getDoc(),
    });
    channel.id = doc.id;
    channels.add(channel);
    return channel;
  }

  Future<Message?> sendMessage(
    Message message,
    Channel channel,
  ) async {
    message.text = message.text.trim();
    if (message.text.isEmpty) return null;
    DocumentReference doc = await message.getCol(parent: channel).add({
      "text": message.text,
      "sender": user.getDoc(),
      "attachments": message.attachments,
      "timestamp": message.timestamp,
    });
    message.id = doc.id;
    return message;
  }
}
