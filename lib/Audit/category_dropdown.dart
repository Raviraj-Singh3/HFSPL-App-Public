
import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';
import 'package:HFSPL/utils/globals.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(dynamic value) onChanged;
  const CategoryDropdown({super.key, required this.onChanged});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {

  final DioClient _client = DioClient();

  List<AuditCategoryModel> auditCategories = [];

  Future<List<AuditCategoryModel>> auditCategory() async {
  if (auditCategories.isNotEmpty) {
    return auditCategories;
  }
  try {
    final data = await _client.getAuditCategories(Global_uid);

    // If `data` is already a List<AuditCategoryModel>
    if (data is List<AuditCategoryModel>) {
      auditCategories = data;
    } 
    // If `data` is a List<Map>, map it to `AuditCategoryModel`
    else if (data is List) {
      auditCategories = data.map((e) {
        final map = e as Map<String, dynamic>;
        return AuditCategoryModel(
          categoryId: map['CategoryId'],
          category: map['Category'],
        );
      }).toList();
    }

    return auditCategories;
  } catch (e) {
    print("error in auditCategories dropdown $e");
    throw Exception("error fetching data");
  }
}

  
  int? selectedValue;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuditCategoryModel>>(
        future: auditCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
                hint: const Text("Select Category"),
                value: selectedValue,
                items: snapshot.data!.map((e) {
                  return DropdownMenuItem(
                      value: e.categoryId,
                      child: Text(e.category.toString()));
                }).toList(),
                onChanged: (value) {
                  // print('value $value');
                  widget.onChanged(value);
                  setState(() {
                    selectedValue = value;
                  });
                });
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}