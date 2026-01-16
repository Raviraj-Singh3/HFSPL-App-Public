import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Collection-Calling/collection_calling_response_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/pick_date_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CollectionCalling extends StatefulWidget {
  const CollectionCalling({super.key});

  @override
  State<CollectionCalling> createState() => _CollectionCallingState();
}

class _CollectionCallingState extends State<CollectionCalling> {
  final DioClient _client = DioClient();
  List<CollectionCallingResponse>? originalList;
  List<CollectionCallingResponse> filteredList = [];
  bool isLoading = false;
  DateTime? selectedDate;
  String _filterOption = "All";
  List callingRemarks = [];
  List callingSpouseRemarks = [];


  Future<void> _fetch() async {

    if (selectedDate == null) {
      showMessage(context, "Please select a date first");
      return;
    }

    
    try {
      setState(() => isLoading = true);
      var response = await _client.getCollectionCalling(selectedDate!, Global_uid);
      setState(() {
        originalList = response;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, "Error $e");
    }
    
  }

  void _getRemarks() async {
    try {
      var response = await _client.getCallingRemarks();
      setState(() {
        callingRemarks = response;
      });
    } catch (e) {
      showMessage(context, "$e");
    }
  }
  void _getSpouseRemarks() async {
    try {
      var response = await _client.getSpouseWorkRemarks();
      setState(() {
        callingSpouseRemarks = response;
      });
    } catch (e) {
      showMessage(context, "$e");
    }
  }

  datepicker() async {
    selectedDate = await pickDate(context, DateTime.now(), DateTime.now(), DateTime(2100));
    setState(() {});
    _fetch();
  }
  void _applyFilter() {
  setState(() {
    filteredList = originalList!.where((element) =>
        _filterOption == "All" ||
        (_filterOption == "Done" && element.finalRemark == "Done") ||
        (_filterOption == "Not Done" && element.finalRemark != "Done")
    ).toList();
  });
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRemarks();
    _getSpouseRemarks();
    // _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Collection Calling"),
      ),
      body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                     Card(
  margin: const EdgeInsets.all(12),
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: datepicker,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Filter by Status", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: ["All", "Done", "Not Done"].map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: _filterOption,
                  onChanged: (value) {
                    setState(() {
                      _filterOption = value!;
                      _applyFilter();
                    });
                  },
                ),
                Text(option),
              ],
            );
          }).toList(),
        ),
      ],
    ),
  ),
),
      // const SizedBox(height: 10),
      isLoading
          ? const CircularProgressIndicator()
          : originalList != null && originalList!.isEmpty
              ? const Expanded(child: Center(child: Text("No Members Found")))
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final member = filteredList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${member.name} (${member.relativeName})",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  // IconButton(
                                  //   icon: const Icon(Icons.call, color: Colors.green),
                                  //   onPressed: () => _callNumber(member.memberPhone1.toString()),
                                  // ),
                                ],
                              ),
                              // Text("Loan #: ${member.loanNumber}", style: TextStyle(color: Colors.grey[600])),
                              Text("Group: ${member.groupName}"),
                              Text("Address: ${member.memberAddress}"),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text("Phone1: ${member.memberPhone1}"),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.call, color: Colors.green),
                                    onPressed: () => _callNumber(member.memberPhone1.toString()),
                                  ),
                                ],
                              ),
                              if (member.memberPhone2 != null && member.memberPhone2!.isNotEmpty)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text("Phone2: ${member.memberPhone2}"),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.call, color: Colors.green),
                                    onPressed: () => _callNumber(member.memberPhone2.toString()),
                                  ),
                                ],
                              ),
                              if (member.firstFilledNumber != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text("First Filled Number: ${member.firstFilledNumber}"),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.call, color: Colors.green),
                                    onPressed: () => _callNumber(member.firstFilledNumber.toString()),
                                  ),
                                ],
                              ),
                              if (member.updatedNumbers != null && member.updatedNumbers!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                                    child: Text("Updated Numbers:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  ...member.updatedNumbers!.map((number) => 
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(number.toString()),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.call, color: Colors.green),
                                          onPressed: () => _callNumber(number.toString()),
                                        ),
                                      ],
                                    ),
                                  ).toList(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _infoChip("EMI: ₹${member.emi}"),
                                  _infoChip("Overdue: ₹${member.overdue}"),
                                  _infoChip("Demand: ₹${member.demand}"),
                                  _infoChip("I.N.: ${member.installment}"),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (member.finalRemark!.isNotEmpty)
                                Text("Final Remark: ${member.finalRemark} (${member.finalRemarkStatus})",
                                    style: const TextStyle(fontStyle: FontStyle.italic)),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(onPressed: (){
                                  showUpdateDialog(context, member);
                                }, 
                                child: Text("Update"))),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    ],
  ),
),

    );
  }
  Widget _infoChip(String text) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}
Future<void> _callNumber(String phoneNumber) async {
  if(phoneNumber.isEmpty || phoneNumber == "null"){
    showMessage(context, "Phone number is empty");
    return;
  }
  // print("phoneNumber: $phoneNumber");
  if (phoneNumber.isNotEmpty) {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == null || !res) {
      showMessage(context, "Failed to make the call");
    }
  }
}

void showUpdateDialog(BuildContext context, CollectionCallingResponse member) {
  String? selectedRemark = member.finalRemark!.isEmpty ? null : member.finalRemark;
  String? selectedRemarkStatus = member.finalRemarkStatus;
  String? selectedOccupation;
  DateTime? selectedReminderDate;
  final notesController = TextEditingController();
  // Store the parent context
  final parentContext = context;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (builderContext, setState) {
          Future<void> pickReminderDate(BuildContext context) async {
            final picked = await pickDate(context, DateTime.now(), DateTime.now(), DateTime(2100));
            if (picked != null) {
              setState(() {
                selectedReminderDate = picked;
              });
            }
          }

          return AlertDialog(
            title: const Text("Update Remarks"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Select Status"),
                    value: selectedRemark,
                    onChanged: (value) => setState(() => selectedRemark = value),
                    items: ["Not Done", "Done"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Object>(
                    decoration: const InputDecoration(labelText: "Select Remark"),
                    value: selectedRemarkStatus,
                    onChanged: (value) => setState(() => selectedRemarkStatus = value.toString()),
                    items: callingRemarks
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Object>(
                    decoration: const InputDecoration(labelText: "Select husband Occupation"),
                    value: selectedOccupation,
                    onChanged: (value) => setState(() => selectedOccupation = value.toString()),
                    items: callingSpouseRemarks
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    // maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Notes for Next Reminder",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Next Reminder Date (Optional)",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton.icon(
                    onPressed: () => pickReminderDate(builderContext),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedReminderDate == null
                          ? "Select Date"
                          : "${selectedReminderDate!.day}/${selectedReminderDate!.month}/${selectedReminderDate!.year}",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedRemark == null) {
                    showMessage(parentContext, "Please select a status");
                    return;
                  }
                  if (selectedRemarkStatus == null) {
                    showMessage(parentContext, "Please select a remark");
                    return;
                  }
                  var data = {
                    "ClientId": member.clientId,
                    "CallerId": Global_uid,
                    "statusRemark": selectedRemark,
                    "remark": selectedRemarkStatus,
                    "notes": notesController.text,
                    "spouseWork": selectedOccupation,
                    "ReminderDate": selectedReminderDate?.toIso8601String(),
                  };
                  try {
                    var response = await _client.postCollectionCalling(data);
                    showMessage(parentContext, "Successfully updated");
                    _fetch();
                  } catch (e) {
                    showMessage(parentContext, "$e");
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      );
    },
  );
}


}