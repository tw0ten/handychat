import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

//todo: ok fetching is working. im not sure wh. wait no. all cache is inside account. so i just fetch everything account has access to at first? channels at least. shallowly? eh. only fetch user ids from channels at first? nah aae eeh fuck. im ean its small enough for now to fetch everything ever recursively
//yuh i should use references and ig theyre just stringssss or not! maybe in get they are but in set theyre probs different

final Account account = Account(id: "0");

abstract class FSDocument {
  String id;
  FSDocument({required this.id});
}

class Channel extends FSDocument {
  String name;
  String picture;
  List<User> users;
  List<Message> messages;

  Channel({
    required super.id,
    required this.name,
    required this.picture,
    required this.users,
    required this.messages,
  });
}

class User extends FSDocument {
  static int maxNameLength = 16;
  String name;
  String picture;
  List<Channel> channels;

  User({
    required super.id,
    required this.name,
    required this.picture,
    required this.channels,
  });
}

class Account {
  User user;

  Account({required String id})
      : user = User(
          id: id,
          name: "",
          picture: "https://tw0ten.github.io/resources/assets/image/me64.png",
          channels: [],
        );

  void updateUser() async {}

  Future<User?> fetchUser(String id) async {
    DocumentReference doc = firestore.collection("users").doc(id);
    DocumentSnapshot ss =
        await doc.get(const GetOptions(source: Source.serverAndCache));
    return User(
      id: id,
      name: ss.get("name"),
      picture: ss.get("picture"),
      channels: [],
    );
  }

  Future<Channel?> fetchChannel(String id) async {
    DocumentReference doc = firestore.collection("channels").doc(id);
    DocumentSnapshot ss =
        await doc.get(const GetOptions(source: Source.serverAndCache));
    
    return Channel(
      id: id,
      name: ss.get("name"),
      picture: ss.get("picture"),
      users: [user],
      messages: [],
    );
  }

  Future<Channel> create(
    String name, {
    String picture =
        "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png",
  }) async {
    DocumentReference channel = await firestore.collection("channels").add({
      "name": name,
      "picture": picture,
      "users": [firestore.collection("users").doc(user.id)],
    });
    await firestore.collection("users").doc(user.id).update({
      "channels": channel,
    });
    final c = Channel(
      id: channel.id,
      name: name,
      picture: picture,
      users: [user],
      messages: [],
    );
    user.channels.add(c);
    return c;
  }

  Future<Message?> sendMessage(String text, Channel channel,
      {List<String> attachments = const []}) async {
    text = text.trim();
    if (text.isEmpty) return null;
    DateTime now = DateTime.now();
    DocumentReference doc = await firestore
        .collection("channels")
        .doc(channel.id)
        .collection("messages")
        .add({
      "text": text,
      "sender": firestore.collection("users").doc(user.id),
      "attachments": attachments,
      "timestamp": now,
    });
    return Message(
      id: doc.id,
      text: text,
      sender: user,
      timestamp: now,
      attachments: attachments,
    );
  }
}

class Message extends FSDocument {
  String text;
  User sender;
  DateTime timestamp;
  List<String> attachments;

  String formatTimestamp() {
    DateTime ts = timestamp.toLocal();
    return "${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}|${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}";
  }

  Message({
    required super.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.attachments,
  });
}
