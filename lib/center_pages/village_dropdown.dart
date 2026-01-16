import 'dart:io';

import 'package:flutter/material.dart';
import 'package:HFSPL/utils/globals.dart';

import '../models/dropdown_model.dart';
import '../network/networkcalls.dart';

class VillageDropDown extends StatefulWidget {
  final Function(dynamic value) onChanged;
  const VillageDropDown({super.key, required this.onChanged});

  @override
  State<VillageDropDown> createState() => _VillageDropDownState();
}

class _VillageDropDownState extends State<VillageDropDown> {
  @override
  void initState() {
    super.initState();
  }

  final DioClient _client = DioClient();

  List<DropdownModel> finalList = [];

  Future<List<DropdownModel>> getVillage() async {
    if (finalList.isNotEmpty) {
      return finalList;
    }
    try {
      final data = await _client.getVillageListByUserid(Global_uid);
      finalList = data.map((e) {
        final map = e as Map<String, dynamic>;
        return DropdownModel(iD: map['ID'], village: map['Village']);
      }).toList();
      return finalList;
    } on SocketException {
      throw Exception("no internet");
    } catch (e) {
      print("error in village dropdown $e");
    }
    throw Exception("error fetching data");
  }

  var selectedValue;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownModel>>(
        future: getVillage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
                hint: const Text("Select Village"),
                value: selectedValue,
                items: snapshot.data!.map((e) {
                  return DropdownMenuItem(
                      value: e.iD.toString(),
                      child: Text(e.village.toString()));
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
