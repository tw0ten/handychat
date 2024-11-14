import 'package:flutter/material.dart';

Future<bool> confirm(BuildContext context, String title) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                child: const Text("cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(
                  "confirm",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ) ??
      false;
}
