import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handychat/main/db.dart' as db;

final FirebaseAuth _auth = FirebaseAuth.instance;

Stream<User?> authStateChanges() {
  return _auth.authStateChanges();
}

final Account account = Account();

class Account {
  db.User user = db.User();
  final Map<String, db.Channel> _channels = {};
  final StreamController<List<db.Channel>> _channelStream = StreamController();
  String email = "";

  Account();

  db.Channel channel(String id) {
    return _channels[id] ?? db.Channel(id: id, onUpdate: () {});
  }

  Stream<List<db.Channel>> channels() {
    return _channelStream.stream;
  }

  void _updateChannels() {
    //TODO: sort by newest message
    _channelStream.add(_channels.values.toList());
  }

  Future<void> logout() async {
    email = "";
    _channels.clear();
    user = db.User();
    return await _auth.signOut();
  }

  Future<void> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) return;
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    email = _auth.currentUser!.email!;
    user.id = cred.user!.uid;
    user.name = name;
    user.getDoc().set(user.toMap());
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return;
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await postLogin();
  }

  Future<void> postLogin() async {
    if (user.id != null) return;
    user.id = _auth.currentUser!.uid;
    email = _auth.currentUser!.email!;
    var ch = (await user.fetch()).get("channels");
    for (DocumentReference doc in ch) {
      db.Channel c = db.Channel(
        id: doc.id,
        onUpdate: _updateChannels,
      );
      if (!(await c.fetch()).exists) continue;
      _channels.putIfAbsent(c.id!, () => c);
    }
    _updateChannels();
  }

  Future<void> updateProfile() async {
    if (user.name!.isEmpty) return;
    final Map<String, dynamic> map = user.toMap();
    map.remove("channels");
    user.getDoc().update(map);
  }

  Future<void> createChannel() async {
    final db.Channel channel = db.Channel(
      name: "new channel",
      onUpdate: _updateChannels,
    );
    channel.users.putIfAbsent(user.id!, () => user);
    DocumentReference doc = await channel.getCol().add(channel.toMap());
    channel.id = doc.id;
    _channels.putIfAbsent(channel.id!, () => channel);
    _updateChannels();

    List<DocumentReference> channels = [];
    for (db.Channel c in _channels.values) {
      channels.add(c.getDoc());
    }
    await user.getDoc().update({
      "channels": channels,
    });
  }

  Future<void> updateChannel(db.Channel c) async {
    _channels.update(c.id!, (_) => c);
    _updateChannels();
    await c.getDoc().update(c.toMap());
  }

  Future<void> deleteChannel(db.Channel channel) async {
    _channels.remove(channel.id);
    _updateChannels();
    await channel.getDoc().delete();
  }
}
