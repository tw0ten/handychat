import 'package:cloud_firestore/cloud_firestore.dart';

//you already know it baby
//the classic
//TODO: REDO

const defaultPicutreUrl = "https://raw.githubusercontent.com/tw0ten/dotarch/main/etc/cat.png";

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

  DocumentSnapshot? lastMessage;

  Channel({
    super.id,
    this.name = "-",
    this.picture = defaultPicutreUrl,
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
    this.picture = defaultPicutreUrl,
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
  List<String> attachments;

  String formatTimestamp() {
    DateTime ts = timestamp.toLocal();
    return "${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}|${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}";
  }

  Message({
    super.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.attachments,
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
    user.getDoc().update({
      "name": user.name,
      "picture": user.picture,
    });
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
    channel.messages = await fetchMessages(channel, 1) ?? [];
    return channel;
  }

  Future<List<Message>?> fetchMessages(Channel channel, int batch) async {
    Query query = channel
        .getDoc()
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(batch);

    final DocumentSnapshot? last = channel.lastMessage;
    if (last != null) {
      query = query.startAfterDocument(last);
    }

    List<DocumentSnapshot> arr =
        (await query.get(const GetOptions(source: Source.serverAndCache))).docs;
    List<Message> msgs = [];
    for (DocumentSnapshot msg in arr) {
      User sender = User(id: (msg.get("sender") as DocumentReference).id);
      for (User u in channel.users) {
        if (u.id == sender.id) {
          sender = u;
          break;
        }
      }
      List<String> attachments = [];
      for(dynamic i in msg.get("attachments")) {
        attachments.add(i as String);
      }
      msgs.add(Message(
        id: msg.id,
        text: msg.get("text") as String,
        sender: sender,
        timestamp: (msg.get("timestamp") as Timestamp).toDate(),
        attachments: attachments,
      ));
      channel.lastMessage = msg;
    }
    return msgs;
  }

  Future<Channel> create(Channel channel) async {
    DocumentReference doc = await channel.getCol().add({
      "name": channel.name,
      "picture": channel.name,
      "users": [user.getDoc()],
    });
    this.channels.add(channel);
    List<DocumentReference> channels = [];
    for (Channel c in this.channels) {
      channels.add(c.getDoc());
    }
    await user.getDoc().update({
      "channels": channels,
    });
    channel.id = doc.id;
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
