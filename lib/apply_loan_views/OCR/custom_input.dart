import 'package:flutter/material.dart';

class CustomInputColumn extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final VoidCallback onPressed;
  final String buttonText;

  const CustomInputColumn({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          onTapOutside: (PointerDownEvent event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            label: Text(labelText),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onPressed, child: Text(buttonText)),
      ],
    );
  }
}