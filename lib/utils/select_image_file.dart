import 'dart:io';
import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data';
import 'package:HFSPL/Review_Update_KYC_Photos/Functions/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoQuestionWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  // final String? imageString; // Base64 string from server
  final File? initialFile; // Local File if selected

  const PhotoQuestionWidget({
    Key? key,
    required this.onImageSelected,
    // this.imageString,
    this.initialFile,
  }) : super(key: key);

  @override
  State<PhotoQuestionWidget> createState() => _PhotoQuestionWidgetState();
}

class _PhotoQuestionWidgetState extends State<PhotoQuestionWidget> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialFile;
  }

  // Show dialog for Camera or Gallery selection
  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source"),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text("Camera"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.image),
            label: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  // Pick image from Camera or Gallery
_pickImage(ImageSource source) async {
  File image;
  if (source == ImageSource.camera) {
    image = await pickImageFromCamera();
  } else {
    image = await pickImageFromGallary();
  }

  setState(() {
    _selectedImage = image;
  });

  widget.onImageSelected(image);
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceDialog, // Tap to Choose Camera/Gallery
        child: Container(
          // height: 250,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, size: 40, color: Colors.teal),
                        Text("Tap to Capture/Select", style: TextStyle(color: Colors.teal.shade700)),
                      ],
                    ),
                ),
        ),
      ),
    );
  }
}
