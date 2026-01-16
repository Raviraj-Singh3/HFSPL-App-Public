import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final ImagePicker _picker = ImagePicker();

Future<File>  pickImageFromCamera() async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    return compressedFile ?? originalFile;

  } else {
    print('No image selected.');
  }
  throw Exception('No image selected.');
}

Future<File>  pickImageFromGallary() async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    return compressedFile ?? originalFile;

  } else {
    print('No image selected.');
  }
  throw Exception('No image selected.');
}

 Future<File?> compressImage(File imageFile) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress the image
      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        imageFile.path, // Input file path
        targetPath, // Output file path
        quality: 50, // Compression quality (adjust as needed)
        minWidth: 800, // Minimum width (optional)
        minHeight: 800, // Minimum height (optional)
      );

      // Convert XFile to File
      File? compressedFile =
          compressedXFile != null ? File(compressedXFile.path) : null;

      return compressedFile;
    } catch (e) {
      print("Error during compression: $e");
      return null;
    }
  }