import 'package:flutter/material.dart';

class WebImage extends StatelessWidget {
  const WebImage(this.url, {super.key, this.width = 64, this.height = 64});

  final String? url;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url ?? "",
      width: width,
      height: height,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => Image(
        image: const AssetImage("assets/cat.png"),
        width: width,
        height: height,
      ),
    );
  }
}
