
import 'package:flutter/material.dart';

 showWorkHourStartDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false, // prevent accidental dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Working Hours Started"),
        content: const Text(
          "Your working hours have started now.\n\n"
          "Please keep the app and location services ON.\n"
          "Closing the app or turning off location may reduce your working hours.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK, Got it"),
          ),
        ],
      );
    },
  );
}