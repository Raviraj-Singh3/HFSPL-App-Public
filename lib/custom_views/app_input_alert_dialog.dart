import 'package:flutter/material.dart';

import 'app_text_view.dart';

class AppInputAlertDialog extends StatefulWidget {
  final String title;
  final String description;
  final Function(String inputValue) confirmCallback;
  final VoidCallback cancelCallback;
  final String? defaultValue;
  final TextInputType keyboardType;
  final int? maxLength;
  final String hintText;
  final String labelText;
  final bool enabled;

  const AppInputAlertDialog(
      {Key? key,
      required this.title,
      required this.description,
      required this.confirmCallback,
      required this.cancelCallback,
      this.defaultValue,
      this.keyboardType = TextInputType.text,
      this.maxLength,
      this.hintText = 'Enter Text',
      this.labelText = 'Text',
      this.enabled = true})
      : super(key: key);

  @override
  AppInputAlertDialogState createState() => AppInputAlertDialogState();
}

class AppInputAlertDialogState extends State<AppInputAlertDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.defaultValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.description),
            const SizedBox(height: 16),
            AppTextBox(
              controller: _textController,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              hintText: widget.hintText,
              labelText: widget.labelText,
              key: widget.key,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: widget.cancelCallback,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.confirmCallback(_textController.text);
          },
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
