// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:HFSPL/network/networkcalls.dart';

// class BillsPage extends StatefulWidget {
//   const BillsPage({super.key});

//   @override
//   State<BillsPage> createState() => _BillsPageState();
// }

// class _BillsPageState extends State<BillsPage> {
//   File? selectedFile;
//   String? fileName;
//   String? fileType; // 'image' or 'document'
//   bool isLoading = false;
//   final DioClient _client = DioClient();
  
//   // Form fields for BillRecord
//   final TextEditingController billNumberController = TextEditingController();
//   final TextEditingController productNameController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   String selectedCategory = 'Utilities';
  
//   final List<String> categories = [
//     'Utilities',
//     'Office Supplies',
//     'Travel',
//     'Equipment',
//     'Services',
//     'Other'
//   ];
  

//   final ImagePicker _imagePicker = ImagePicker();

//   Future<void> pickImage() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//       );
      
//       if (image != null) {
//         setState(() {
//           selectedFile = File(image.path);
//           fileName = 'bill_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//           fileType = 'image';
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     }
//   }

//   Future<void> pickDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
//       );
      
//       if (result != null) {
//         setState(() {
//           selectedFile = File(result.files.single.path!);
//           fileName = result.files.single.name;
//           fileType = 'document';
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking document: $e')),
//       );
//     }
//   }

//   Future<void> upload() async {
//     if (selectedFile == null || fileName == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a file first')),
//       );
//       return;
//     }

//     if (billNumberController.text.isEmpty || productNameController.text.isEmpty || amountController.text.isEmpty || descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in required fields: Bill Number, Product Name, and Amount')),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       var response = await _client.uploadBill(
//         selectedFile!,
//         fileName!,
//         billNumberController.text,
//         productNameController.text,
//         int.tryParse(amountController.text) ?? 0,
//         descriptionController.text,
//         selectedCategory,
//       );

//       print("response: $response");
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload successful')),
//       );
      
//       // Clear form after successful upload
//       clearForm();
      
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void clearForm() {
//     setState(() {
//       selectedFile = null;
//       fileName = null;
//       fileType = null;
//       billNumberController.clear();
//       productNameController.clear();
//       amountController.clear();
//       descriptionController.clear();
//       selectedCategory = 'Utilities';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Bill'),
//         backgroundColor: Colors.teal.shade700,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // File Selection Section
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Select File',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: pickImage,
//                               icon: const Icon(Icons.camera_alt),
//                               label: const Text('Take Photo'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue.shade600,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: pickDocument,
//                               icon: const Icon(Icons.upload_file),
//                               label: const Text('Upload File'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green.shade600,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (selectedFile != null) ...[
//                         const SizedBox(height: 16),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.green.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 fileType == 'image' ? Icons.image : Icons.description,
//                                 color: Colors.green.shade600,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       fileName!,
//                                       style: const TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       fileType == 'image' ? 'Image File' : 'Document File',
//                                       style: TextStyle(
//                                         color: Colors.grey.shade600,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedFile = null;
//                                     fileName = null;
//                                     fileType = null;
//                                   });
//                                 },
//                                 icon: const Icon(Icons.close),
//                                 color: Colors.red,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Form Fields Section
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Bill Details',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Bill Number
//                       TextFormField(
//                         controller: billNumberController,
//                         decoration: InputDecoration(
//                           labelText: 'Bill Number *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.receipt),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Product Name
//                       TextFormField(
//                         controller: productNameController,
//                         decoration: InputDecoration(
//                           labelText: 'Product Name *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.shopping_cart),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Amount
//                       TextFormField(
//                         controller: amountController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: 'Amount *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.attach_money),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Description
//                       TextFormField(
//                         controller: descriptionController,
//                         keyboardType: TextInputType.text,
//                         decoration: InputDecoration(
//                           labelText: 'Description *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.description),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Category
//                       DropdownButtonFormField<String>(
//                         value: selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.category),
//                         ),
//                         items: categories.map((String category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(category),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCategory = newValue!;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Upload Button
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : upload,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal.shade700,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: isLoading
//                       ? const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Text('Uploading...'),
//                           ],
//                         )
//                       : const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.upload),
//                             SizedBox(width: 8),
//                             Text('Upload Bill'),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     billNumberController.dispose();
//     productNameController.dispose();
//     amountController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }
// }
