import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handychat/main/logic.dart';

final _firestore = FirebaseFirestore.instance;

abstract class FSDocument {
  String? id;

  CollectionReference getCol();
  DocumentReference getDoc() {
    return getCol().doc(id);
  }

  Future<DocumentSnapshot> fetch();

  Map<String, dynamic> toMap();

  FSDocument({this.id});
}

class Channel extends FSDocument {
  String? name;
  String? picture;
  final Map<String, User> users = {};
  final List<Message> messages = [];
  StreamController<List<Message>> _stream = StreamController();
  DocumentSnapshot? _lastMessage;

  void Function() _onUpdate = () {};

  void _updateMessages() {
    _stream.add(messages);
    _onUpdate();
  }

  Future<void> send(Message message) async {
    messages.insert(0, message);
    _updateMessages();
    await message.getCol(parent: this).add(message.toMap());
  }

  Message messageFromDoc(DocumentSnapshot doc) {
    List<String> attachments = [];
    for (String s in doc.get("attachments")) {
      attachments.add(s);
    }
    User sender = User(id: doc.get("sender").id);
    sender = users[sender.id] ?? sender;
    return Message(
      id: doc.id,
      text: doc.get("text"),
      sender: sender,
      timestamp: (doc.get("timestamp") as Timestamp).toDate(),
      attachments: attachments,
    );
  }

  Stream<List<Message>> stream() {
    _stream = StreamController();
    _updateMessages();
    return _stream.stream;
  }

  Channel({
    super.id,
    this.name,
    this.picture,
    required void Function() onUpdate,
  }) {
    _onUpdate = onUpdate;
  }

  @override
  CollectionReference<Object?> getCol() {
    return _firestore.collection("channels");
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "picture": picture,
      "users": users.values.map((u) => u.getDoc()),
    };
  }

  @override
  Future<DocumentSnapshot<Object?>> fetch() async {
    DocumentSnapshot ss =
        await getDoc().get(const GetOptions(source: Source.serverAndCache));
    if (!ss.exists) return ss;
    name = ss.get("name");
    picture = ss.get("picture");
    for (var i in ss.get("users")) {
      final User u = User(id: i.id);
      await u.fetch();
      users.putIfAbsent(u.id!, () => u);
    }
    fetchMessages();
    final Stream<QuerySnapshot> snapshots = getDoc()
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
    snapshots.listen((e) {
      if(e.docs.isEmpty) return;
      if (messages.isEmpty) {
        _lastMessage = e.docs.first;
      }
      final Message msg = messageFromDoc(e.docs.first);
      if (msg.sender.id == account.user.id ||
          messages.isNotEmpty && msg.id == messages.first.id) {
        return;
      }
      messages.insert(0, msg);
      _updateMessages();
    });
    return ss;
  }

  bool _locked = false;
  Future<void> fetchMessages() async {
    if (_locked) return;
    _locked = true;
    Query query = getDoc()
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(10);

    final DocumentSnapshot? last = _lastMessage;
    if (last != null) {
      query = query.startAfterDocument(last);
    }

    List<DocumentSnapshot> arr =
        (await query.get(const GetOptions(source: Source.serverAndCache))).docs;
    for (DocumentSnapshot msg in arr) {
      User sender = User(id: (msg.get("sender") as DocumentReference).id);
      sender = users[sender.id] ?? sender;
      List<String> attachments = [];
      for (String i in msg.get("attachments")) {
        attachments.add(i);
      }
      messages.add(Message(
        id: msg.id,
        text: msg.get("text") as String,
        sender: sender,
        timestamp: (msg.get("timestamp") as Timestamp).toDate(),
        attachments: attachments,
      ));
      _lastMessage = msg;
    }
    _updateMessages();
    _locked = false;
  }
}

class User extends FSDocument {
  //TODO: store channels here? or fix toMap
  String? name;
  String? picture;

  User({
    super.id,
    this.name,
    this.picture,
  });

  Future<void> addChannel(Channel c) async {
    final List<DocumentReference> channels = [];
    for(DocumentReference d in (await getDoc().get(const GetOptions())).get("channels")) {
      channels.add(d);
    }
    channels.add(c.getDoc());
    getDoc().update({
      "channels": channels,
    });
  }

  @override
  CollectionReference<Object?> getCol() {
    return _firestore.collection("users");
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "picture": picture,
      "channels": [],
    };
  }

  @override
  Future<DocumentSnapshot<Object?>> fetch() async {
    DocumentSnapshot ss =
        await getDoc().get(const GetOptions(source: Source.serverAndCache));
    name = ss.get("name");
    picture = ss.get("picture");
    return ss;
  }
}

class Message extends FSDocument {
  String text;
  User sender;
  DateTime timestamp;
  List<String> attachments;

  bool validate() {
    text = text.trim();
    return text.isNotEmpty;
  }

  String formatTimestamp() {
    final DateTime ts = timestamp.toLocal();
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

  @override
  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "sender": sender.getDoc(),
      "timestamp": timestamp,
      "attachments": attachments,
    };
  }

  @override
  Future<DocumentSnapshot<Object?>> fetch() async {
    throw UnimplementedError();
  }
}
