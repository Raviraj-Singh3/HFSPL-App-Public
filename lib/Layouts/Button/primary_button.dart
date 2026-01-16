
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Function() onPressed;
  final bool isLoading;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final dynamic valueToPassBack;
  final EdgeInsets padding;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.valueToPassBack,
    required this.text,
    this.backgroundColor = const Color(0xFF00796B), // Default Teal
    this.textColor = Colors.white,
    this.borderRadius = 16.0, // Updated to a larger radius for a softer look
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 6, // Adds slight elevation for depth
        ),
        onPressed: isLoading
            ? null
            : () {
                onPressed();
              },
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              )
          : Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
