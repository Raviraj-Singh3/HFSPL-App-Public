import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function(dynamic value) onPressed;
  final bool isLoading;
  final String text;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final dynamic valueToPassBack;
  final IconData? icon; // Optional icon parameter

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.valueToPassBack,
    this.isLoading = false,
    this.buttonColor = const Color.fromARGB(255, 67, 38, 235),
    this.textColor = const Color.fromARGB(225, 255, 255, 255),
    this.borderRadius = 20.0, // More rounded corners
    this.padding = const EdgeInsets.symmetric(
        horizontal: 16.0, vertical: 14.0), // Padding adjusted for better look
    this.icon, // Icon optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Increased height for better button size
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                onPressed(valueToPassBack);
              },
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 6.0, // Added elevation for shadow effect
        ),
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor,
                    ),
                    const SizedBox(width: 10), // Spacing between icon and text
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18, // Slightly larger text size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
