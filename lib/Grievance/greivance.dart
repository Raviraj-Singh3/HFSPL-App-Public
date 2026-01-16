import 'dart:convert';
import 'dart:io';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Functions/image_picker.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/select_image_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Greivance/greivance_response_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Greivance extends StatefulWidget {
  const Greivance({super.key});

  @override
  State<Greivance> createState() => _GreivanceState();
}

class _GreivanceState extends State<Greivance> {
  final DioClient _client = DioClient();
  List<GetGrievanceCategoriesResponse> grievanceCategories = [];
  int? selectedSubCategoryId;
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetcha();
  }

  _fetcha() async {
    var data = await _client.getGrievanceCategories();
    if (data.isNotEmpty) {
      setState(() {
        grievanceCategories = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Grievance'),
        backgroundColor: Colors.teal,
      ),
      body: grievanceCategories.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Select a grievance category:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: grievanceCategories.length,
                      itemBuilder: (context, index) {
                        final category = grievanceCategories[index];
                        return ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.grey.shade100,
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            category.title ?? "-",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          children: category.subCategories?.map((sub) {
                                return ListTile(
                                  title: Text(sub.title ?? "-"),
                                  leading: Radio<int>(
                                    value: sub.id!,
                                    groupValue: selectedSubCategoryId,
                                    activeColor: Colors.teal,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSubCategoryId = val;
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedSubCategoryId = sub.id;
                                    });
                                  },
                                );
                              }).toList() ??
                              [],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Submit Grievance"),
                      onPressed: selectedSubCategoryId == null
                          ? null : _askDescription,
                          // : () {
                              // Submit logic here
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text("Grievance submitted for ID: $selectedSubCategoryId"),
                              //   ),
                              // );
                            // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  _askDescription() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Description"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter your grievance description",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PhotoQuestionWidget(
                  onImageSelected: (File imageFile) {
                    setState(() {
                      _selectedImage = imageFile;
                    });
                  },
                  initialFile: _selectedImage,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a description"),
                  ),
                );
                return;
              }
              _submitGrievance();

              Navigator.of(context).pop();
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}

_submitGrievance() async {
  // print("selected image: $_selectedImage");
  // print("selected subcategory id: $selectedSubCategoryId");
  var data = {
    "description": _descriptionController.text,
    "reportedBy": Global_uid,
    "subCategoryId": selectedSubCategoryId,
    "title": grievanceCategories
      .expand((category) => category.subCategories ?? [])
      .firstWhere((subCategory) => subCategory.id == selectedSubCategoryId)
      .title,
      };
  FormData formData = FormData();

  formData.fields.add(MapEntry("data", jsonEncode(data)));

    if (_selectedImage != null) {
      formData.files.add(MapEntry(
        "file",
        await MultipartFile.fromFile(_selectedImage!.path, filename: _selectedImage!.path.split('/').last),
      ));
    }
    context.loaderOverlay.show();
    var response = await _client.postGrievance(formData);
    context.loaderOverlay.hide();
    print( "response : $response");
    showMessage(context, "$response");
    Navigator.pop(context);
  }

}
