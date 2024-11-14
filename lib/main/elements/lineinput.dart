import 'package:flutter/material.dart';

enum LineInputType {
  email(TextInputType.emailAddress),
  password(TextInputType.visiblePassword),
  text(TextInputType.text),
  username(TextInputType.text);

  final TextInputType type;
  const LineInputType(this.type);
}

class LineInput extends StatelessWidget {
  const LineInput({this.controller, this.type=LineInputType.text, this.hint, super.key});

  final TextEditingController? controller;
  final String? hint;
  final LineInputType type;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: type.type,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        hintText: hint ?? type.name,
      ),
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      obscureText: type == LineInputType.password,
      maxLines: 1,
      minLines: 1,
      textAlignVertical: TextAlignVertical.center,
    );
  }
}
