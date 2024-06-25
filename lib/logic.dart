import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Chat {
  int id;
  String name = "chat name";
  AssetImage icon = const AssetImage("assets/cat.png");
  List<User> users = List.empty();
  List<Message> messages = List.empty();
  Chat({required this.id});
}

class User {
  int id;
  static int maxNameLength = 16;

  String name = "username";
  AssetImage picture = const AssetImage("assets/cat.png");
  User({required this.id});
}

class Message {
  int id;
  String text = "message text";
  User sender = User(id: 0);
  Message({required this.id});
}
