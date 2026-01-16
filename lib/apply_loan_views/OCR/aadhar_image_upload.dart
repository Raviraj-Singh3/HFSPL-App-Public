
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:HFSPL/apply_loan_views/OCR/imageUploadTile.dart';

class AadhaarImageUploadExpanded extends StatelessWidget {
  final VoidCallback onTap;
  final File? imageFile;
  final String labelText;

  const AadhaarImageUploadExpanded({
    Key? key,
    required this.onTap,
    required this.imageFile,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ImageUploadTile(
        onTap: onTap,
        imageFile: imageFile,
        labelText: labelText,
      ),
    );
  }
}

class AadhaarImageUploadRow extends StatelessWidget {
  final VoidCallback pickFrontImage;
  final VoidCallback pickBackImage;
  final File? adharFrontImage;
  final File? adharBackImage;

  const AadhaarImageUploadRow({
    Key? key,
    required this.pickFrontImage,
    required this.pickBackImage,
    required this.adharFrontImage,
    required this.adharBackImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AadhaarImageUploadExpanded(
          onTap: pickFrontImage,
          imageFile: adharFrontImage,
          labelText: "Select Front",
        ),
        const SizedBox(width: 10),
        AadhaarImageUploadExpanded(
          onTap: pickBackImage,
          imageFile: adharBackImage,
          labelText: "Select Back",
        ),
      ],
    );
  }
}
