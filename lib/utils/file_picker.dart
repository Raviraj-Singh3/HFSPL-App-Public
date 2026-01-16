import 'package:file_picker/file_picker.dart';

Future<String?> pickPDF() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'], // only PDF files
  );

  if (result != null) {
    String? filePath = result.files.single.path;
    return filePath;
    // print("Picked PDF: $filePath");
    // print("Size: ${result.files.single.size * 0.000001} MB");
  } else {
    // print("User canceled the picker");/
  }
}