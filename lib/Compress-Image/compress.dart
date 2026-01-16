
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> compressImage(File imageFile) async {
  try {
    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Compress the image
    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,     // Input file path
      targetPath,         // Output file path
      quality: 50,        // Compression quality (adjust as needed)
      minWidth: 800,      // Minimum width (optional)
      minHeight: 800,     // Minimum height (optional)
    );

    // Convert XFile to File
    File? compressedFile = compressedXFile != null ? File(compressedXFile.path) : null;

    return compressedFile;
  } catch (e) {
    print("Error during compression: $e");
    return null;
  }
}