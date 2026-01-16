import 'package:flutter/material.dart';

class AppButtonSecondary extends StatelessWidget {
  final Function(dynamic value) onPressed;
  final bool isLoading;
  final String text;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final dynamic valueToPassBack;
  final bool enabled;

  const AppButtonSecondary({
    Key? key,
    required this.onPressed,
    required this.text,
    this.valueToPassBack,
    this.isLoading = false,
    this.buttonColor = const Color(0xFF00796B), // Default teal color
    this.textColor = const Color(0xFF00796B), // Text and border color
    this.borderRadius = 12.0, // Updated for a smoother look
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: (isLoading || !enabled)
          ? null
          : () {
              onPressed(valueToPassBack);
            },
      style: OutlinedButton.styleFrom(
        backgroundColor: enabled ? buttonColor.withOpacity(0.1) : Colors.grey.shade200,
        side: BorderSide(color: enabled ? textColor : Colors.grey.shade400),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: enabled ? textColor : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

