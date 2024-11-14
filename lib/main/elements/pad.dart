import 'package:flutter/material.dart';

class Pad extends StatelessWidget {
  const Pad(this.c, {this.p = 4.0, super.key});

  final Widget c;
  final double p;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(p), child: c);
  }
}
