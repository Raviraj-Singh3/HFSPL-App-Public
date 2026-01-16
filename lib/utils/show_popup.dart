import 'package:flutter/material.dart';

Future<void> showPopup({
  required BuildContext context,
  required String heading,
  required List<Widget> content,
  required String positiveButtonText,
   String? negativeButtonText,
  required VoidCallback onPositive,
  VoidCallback? onNegative,
  bool barrierDismissible = true,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(heading),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: content,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onNegative != null) {
                onNegative();
              }
            },
            child: Text(negativeButtonText ?? ''),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPositive();
            },
            child: Text(positiveButtonText),
          ),
        ],
      );
    },
  );
} 