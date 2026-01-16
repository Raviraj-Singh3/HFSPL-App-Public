import 'package:flutter/material.dart';

class AppTextBox extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final String hintText;
  final String labelText;
  final bool enabled;

  const AppTextBox(
      {super.key,
      required this.controller,
      this.keyboardType = TextInputType.text,
      this.maxLength,
      this.hintText = 'Enter Text',
      this.labelText = 'Text',
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      enabled: enabled,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}
