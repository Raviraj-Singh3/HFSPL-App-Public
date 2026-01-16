
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuditProcessScreen extends StatefulWidget {
  const AuditProcessScreen({super.key});

  @override
  _AuditProcessScreenState createState() => _AuditProcessScreenState();
}

class _AuditProcessScreenState extends State<AuditProcessScreen> {
  String? selectedSnapshotName = "Snapshot Name";
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedFe;
  String? selectedGroup;
  String? selectedClient;

  List<String> auditCategories = ["Category 1", "Category 2", "Category 3"];
  List<String> auditSubCategories = ["SubCategory 1", "SubCategory 2"];
  List<String> feOptions = ["FE Option 1", "FE Option 2"];
  List<String> groupOptions = ["Group 1", "Group 2"];
  List<String> clientOptions = ["Client 1", "Client 2"];

  List<XFile> imageList = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSnapshotName ?? "Audit Process"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => _selectCategory(),
              child: Text(
                selectedCategory ?? "Select Audit Category",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () => _selectSubCategory(),
              child: Text(
                selectedSubCategory ?? "Select Audit Sub-Category",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            if (selectedCategory == "FE")
              TextButton(
                onPressed: () => _selectFe(),
                child: Text(
                  selectedFe ?? "Select FE",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            if (selectedCategory == "GM")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => _selectFe(),
                    child: Text(
                      selectedFe ?? "Select FE",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectGroup(),
                    child: Text(
                      selectedGroup ?? "Select Group",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            if (selectedCategory == "CV")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => _selectFe(),
                    child: Text(
                      selectedFe ?? "Select FE",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectGroup(),
                    child: Text(
                      selectedGroup ?? "Select Group",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectClient(),
                    child: Text(
                      selectedClient ?? "Select Client",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _submitAudit(),
              child: Text("Submit Audit"),
            ),
            SizedBox(height: 16.0),
            _buildImageListView(),
          ],
        ),
      ),
    );
  }

  void _selectCategory() async {
    String? category = await _showSelectionDialog(auditCategories, "Select Category");
    if (category != null) {
      setState(() {
        selectedCategory = category;
        selectedSubCategory = null;
        selectedFe = null;
        selectedGroup = null;
        selectedClient = null;
      });
    }
  }

  void _selectSubCategory() async {
    String? subCategory = await _showSelectionDialog(auditSubCategories, "Select Sub-Category");
    if (subCategory != null) {
      setState(() {
        selectedSubCategory = subCategory;
      });
    }
  }

  void _selectFe() async {
    String? fe = await _showSelectionDialog(feOptions, "Select FE");
    if (fe != null) {
      setState(() {
        selectedFe = fe;
      });
    }
  }

  void _selectGroup() async {
    String? group = await _showSelectionDialog(groupOptions, "Select Group");
    if (group != null) {
      setState(() {
        selectedGroup = group;
      });
    }
  }

  void _selectClient() async {
    String? client = await _showSelectionDialog(clientOptions, "Select Client");
    if (client != null) {
      setState(() {
        selectedClient = client;
      });
    }
  }

  Future<String?> _showSelectionDialog(List<String> options, String title) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: options
                  .map((option) => ListTile(
                        title: Text(option),
                        onTap: () => Navigator.pop(context, option),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(int questionId) async {
    final XFile? pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageList.add(pickedImage);
      });
    }
  }

  Widget _buildImageListView() {
    return imageList.isEmpty
        ? Text("No images selected.")
        : SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    children: [
                      Image.file(File(imageList[index].path), width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              imageList.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  void _submitAudit() {
    if (selectedCategory == null ||
        selectedSubCategory == null ||
        (selectedCategory == "FE" && selectedFe == null) ||
        (selectedCategory == "GM" && (selectedFe == null || selectedGroup == null)) ||
        (selectedCategory == "CV" &&
            (selectedFe == null || selectedGroup == null || selectedClient == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields before submitting.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Audit submitted successfully.")),
    );
  }
}
