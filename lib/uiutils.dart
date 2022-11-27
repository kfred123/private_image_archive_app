import 'package:flutter/material.dart';

void showDebugDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          ));
}