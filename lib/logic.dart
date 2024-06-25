import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

final Account account = Account(
  id: "xd",
  name: "b",
  picture: "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png",
  channels: [
    Channel(id: "id", name: "name", picture: "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png", users: [], messages: [])
  ],
);

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

class Account extends User {
  Account({
    required super.id,
    required super.name,
    required super.picture,
    required super.channels,
  });

  Future<Channel> create(String name,
      {String picture =
          "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png"}) async {
    DocumentReference channel = await firestore.collection("channels").add({
      "name": name,
      "picture": picture,
      "users": [firestore.collection("users").doc(id)],
    });
    await firestore.collection("users").doc(id).update({
      "channels": channel,
    });
    final c = Channel(
      id: channel.id,
      name: name,
      picture: picture,
      users: [this],
      messages: [],
    );
    channels.add(c);
    return c;
  }

  //todo func for well validating it, returning optional whereas this is future

  Future<Message> sendMessage(String text, Channel channel,
      {List<String> attachments = const []}) async {
    text = text.trim();
    return Message(id: " ", text: text, sender: this, attachments: attachments);
  }
}

class Message extends FSDocument {
  String text;
  User sender;
  List<String> attachments;

  Message(
      {required super.id,
      required this.text,
      required this.sender,
      required this.attachments});
}
