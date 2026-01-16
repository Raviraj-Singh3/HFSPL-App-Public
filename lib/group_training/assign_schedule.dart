import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/network/responses/cgt/hm_model.dart';
import 'package:HFSPL/network/requests/post_cgt_model.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:dio/dio.dart';


class GroupTrainingDay1 extends StatefulWidget {
  const GroupTrainingDay1({super.key});

  @override
  State<GroupTrainingDay1> createState() => _GroupTrainingDay1State();
}

class _GroupTrainingDay1State extends State<GroupTrainingDay1> {
  final DioClient _client = DioClient();
  List<HmModel> hmResponseList = [];
  Map<String, bool> isGroupChecked = {};
  DateTime? selectedDate;

  bool isLoading = true;

  // Method to pick date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now, // Set today as the initial date
      firstDate: now, // Set minimum date to today
      lastDate:
          now.add(const Duration(days: 14)), // Max date is 14 days from today
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Update selected date
      });
    }
  }

  // Method to handle Assign button click
  void _onAssignClicked() async {
    bool isAnyChecked = isGroupChecked.containsValue(true);

    if (!isAnyChecked) {
      // Show a message if no checkboxes are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check at least one group.')),
      );
      return;
    }

    await _pickDate(
        context); // Show date picker if at least one checkbox is checked

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    // Prepare the selected groups for the API call
    List<String> selectedGroups = isGroupChecked.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    await postCGT(
         selectedDate.toString(), selectedGroups, hmResponseList);
  }

  

  postCGT(String cgtDay1, List<String> selectedGroups, List<HmModel> groupList)async {
    List<RequestPostCGTItem> items = [];

    for (String groupid in selectedGroups) {
       HmModel? itemGroup = groupList.firstWhere(
         (group) => group.groupid == groupid,
       );

    if (itemGroup != null) {
         List<Member> listMembers = itemGroup.passmembers!.map((m) {
           return Member(
             name: m.membername,
             vid: m.vid,
             cgtmemberid: "", // Set as empty string, modify as necessary
             relative: m.spousename,
             phone: m.phone.toString(),
             otp: m.otp,
            otpEntered: m.otpEntered,
           );
          }).toList();

      items.add(RequestPostCGTItem(
           cgtday1: cgtDay1,
           feid: Global_uid,
           groupid: itemGroup.groupid!,
           group: itemGroup.groupname,
           isSync: "false",
           members: listMembers,
         ));
       }
     }

     try {
        var response = await _client.postCGT(items);
        
          if (response.statusCode == 200) {
          // Handle success
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CGT scheduled successfully!')),
          );
          //refresh page 
          setState(() {
            fetch();
          });
        } else {
          // Handle API error
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule CGT.')),
          );
        }
     }
     catch (e){
         print("error... $e");
         if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('$e')),
          );
     }

  }

  fetch() async {
    try {
      
      var response = await _client.getHmResult(Global_uid);
      
      setState(() {
        hmResponseList = response;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("$e")));

      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    fetch(); // Fetch the data on init
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Group Training Day 1')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (hmResponseList.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Group Training Day 1')),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Group Training Day 1"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                      itemCount: hmResponseList.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hmResponseList[index].groupname!,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                              'Total Members: ${hmResponseList[index].passmembers!.length}')
                                        ],
                                      ),
                                    ),
                                    hmResponseList[index].cgt_status! > 0
                                    ?
                                      Text("Assigned", style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontStyle: FontStyle.italic
                                      ),)
                                    : Checkbox(
                                      value: isGroupChecked[
                                              hmResponseList[index].groupid!] ??
                                          false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isGroupChecked[hmResponseList[index]
                                              .groupid!] = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            FilledButton(
                onPressed: _onAssignClicked, child: const Text("Assign")),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
