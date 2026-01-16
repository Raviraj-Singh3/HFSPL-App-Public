
import 'package:flutter/material.dart';

void showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3), // Customize duration if needed
      behavior: SnackBarBehavior.floating, // Optional: for a floating snackbar
    ),
  );
}
