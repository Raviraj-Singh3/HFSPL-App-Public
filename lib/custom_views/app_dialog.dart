import 'package:flutter/material.dart';

class AppConfirmAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback confirmCallback;
  final VoidCallback cancelCallback;

  const AppConfirmAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.confirmCallback,
    required this.cancelCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: cancelCallback,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: confirmCallback,
          child: const Text('Confirm'),
        ),
      ],
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
    );
  }
}
