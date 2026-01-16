import 'dart:io';

import 'package:HFSPL/Compress-Image/compress.dart';
import 'package:HFSPL/apply_loan_views/OCR/aadhar_image_upload.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_pdf_converter/image_to_pdf_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class OcrAadhar extends StatefulWidget {
  const OcrAadhar({super.key});

  @override
  State<OcrAadhar> createState() => _OcrAadharState();
}

class _OcrAadharState extends State<OcrAadhar> {
    final DioClient _client = DioClient();
  File? _adhar_front_image;
  File? _adhar_back_image;
    final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImageFromCameraForPdf(Function(File?) setImage) async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    setState(() {
      setImage(compressedFile); // Use compressed file if available, else use original
    });

    print("Selected Image: ${compressedFile}");
  } else {
    print('No image selected.');
  }
}

void _updateFrontImage(File? image) {
  _adhar_front_image = image;
}

void _updateBackImage(File? image) {
  _adhar_back_image = image;
}

Future<void> _pickImageFromCamera(Function(File?) setImage) async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await _compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    setState(() {
      setImage(compressedFile ?? originalFile);
    });

    print("Selected Image: ${compressedFile ?? originalFile}");
  } else {
    print('No image selected.');
  }
}


  Future<File?> _compressImage(File imageFile) async {
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

  _convertPdf() async {
    try {
      // Generate PDF as a File object
      File response = await ImageToPdf.imageList(
        listOfFiles: [_adhar_front_image, _adhar_back_image],
      );

      // setState(() {
      //   _adharPdf = response;
      // });

      return response;
    } catch (e) {
      print("Error converting PDF $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error converting PDF $e")));
    }
  }

  fetchOetOcr() async {
    if (_adhar_front_image == null || _adhar_back_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("2 Images required")));
      return;
    }
   
    try {
      File pdf = await _convertPdf();
      FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
      pdf.path,
      filename: pdf.path.split('/').last, // Extract filename from path
    ),
    "type": "AADHAR",
    "back": "both"
  });
      var response = await _client.paySprintOcr(formData);
      print("response $response");
    } catch (e) {
      print("error $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aadhar verify"),),
      body: pickImages()
    );
  }

    Column pickImages() {
    return Column(children: [
      const Text(
        "Pick Images",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
      const SizedBox(height: 20),
      // Image Display Section
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Colors.purple.shade50,
        ),
        child: AadhaarImageUploadRow(
          pickFrontImage: () => _pickImageFromCameraForPdf(_updateFrontImage),
          pickBackImage: () => _pickImageFromCameraForPdf(_updateBackImage),
          adharFrontImage: _adhar_front_image,
          adharBackImage: _adhar_back_image,
        ),
      ),
      const SizedBox(height: 20),
      // OCR
      if (_adhar_front_image != null && _adhar_back_image != null)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          onPressed: fetchOetOcr,
          child: const Text("Submit"),
        ),

        const SizedBox(
        height: 20,
      ),
        

      const SizedBox(
        height: 20,
      ),
    ]);
  }
}