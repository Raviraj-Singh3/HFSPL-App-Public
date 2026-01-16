
import 'package:flutter/material.dart';
import 'dart:io';

class ImageUploadTile extends StatelessWidget {
  final VoidCallback onTap;
  final File? imageFile;
  final String labelText;

  const ImageUploadTile({
    Key? key,
    required this.onTap,
    required this.imageFile,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload, size: 40, color: Colors.purple),
                  Text(labelText, style: const TextStyle(color: Colors.purple)),
                ],
              ),
      ),
    );
  }
}