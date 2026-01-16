import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/OD/od_calling_remark_response_model.dart';
import 'package:HFSPL/network/responses/OD/od_group_list.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallScreen extends StatefulWidget {
  final OdMember member;
  final int clientId;
  const CallScreen({super.key, required this.member, required this.clientId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final DioClient _client = DioClient();
  OverdueCallingRemarkResponse? overdueCallingRemarkResponse;
  bool isLoading = true;
  bool showAllRemarks = false;
  TextEditingController notesController = TextEditingController();
  DateTime? selectedReminderDate;

  List<String> remarkList = [];
  List<String> reasonList = [];

  String? selectedRemark;
  String? selectedReason;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      // Fetch both calling remarks and remarks/reasons data
      var response = await _client.getOverdueCallingRemark(widget.clientId);
      var remarksReasonsResponse = await _client.getRemarksAndReasons();
      
      setState(() {
        overdueCallingRemarkResponse = response;
        // Extract remarks and reasons from API response
        if (remarksReasonsResponse != null) {
          remarkList = List<String>.from(remarksReasonsResponse['Remarks'] ?? []);
          reasonList = List<String>.from(remarksReasonsResponse['Reasons'] ?? []);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedReminderDate = picked);
    }
  }

Future<void> _callNumber(String phoneNumber) async {
  if (phoneNumber.isNotEmpty) {
    // print("Calling $phoneNumber");
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == null || !res) {
      // You can show a fallback message if needed
      showMessage(context, "Call failed or was cancelled.");
    }
  } else {
    showMessage(context, "Phone number is empty.");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Screen"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🧑 Member Info
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(widget.member.memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Spouse: ${widget.member.spouse}"),
                          Text("OD Start Date: ${widget.member.odStartDate}"),
                          Text("Mobile: ${widget.member.mobile}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _callNumber(widget.member.mobile),
                        tooltip: "Call ${widget.member.mobile}",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 📋 Existing Remark
                  if (overdueCallingRemarkResponse != null) ...[
                    const Text("Call Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    // Display Final Remark and Status prominently
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetail("Final Remark", overdueCallingRemarkResponse?.finalRemark ?? "N/A"),
                            _buildDetail("Status", overdueCallingRemarkResponse?.finalRemarkStatus ?? "N/A"),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Show More button if there are remark details
                    if (overdueCallingRemarkResponse?.remarkDetails != null && 
                        overdueCallingRemarkResponse!.remarkDetails!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Call History", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () => setState(() => showAllRemarks = !showAllRemarks),
                            icon: Icon(showAllRemarks ? Icons.expand_less : Icons.expand_more),
                            label: Text(showAllRemarks ? "Less" : "More"),
                          ),
                        ],
                      ),
                      
                      if (showAllRemarks && overdueCallingRemarkResponse?.remarkDetails != null) ...[
                        const SizedBox(height: 8),
                        ...overdueCallingRemarkResponse!.remarkDetails!.map((remark) => 
                          _buildRemarkCard(remark)
                        ).toList(),
                      ],
                    ],
                    
                    const Divider(),
                  ],

                  /// 🧾 New Input
                  const Text("Add New Remark", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Select Remark"),
                    value: selectedRemark,
                    onChanged: (value) => setState(() => selectedRemark = value),
                    items: remarkList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Select Reason"),
                    value: selectedReason,
                    onChanged: (value) => setState(() => selectedReason = value),
                    items: reasonList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    // maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Notes for Next Reminder",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Next Reminder Date (Optional)", style: TextStyle(color: Colors.grey[700])),
                  TextButton.icon(
                    onPressed: () => _pickDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedReminderDate == null
                          ? "Select Date"
                          : "${selectedReminderDate!.day}/${selectedReminderDate!.month}/${selectedReminderDate!.year}",
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🚀 Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Submit"),
                      onPressed: _submitData,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildRemarkCard(RemarkDetail remark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    remark.remark ?? "N/A",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Text(
                  _formatDateTime(remark.dateTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (remark.notes != null && remark.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Notes: ${remark.notes}",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              "By: ${remark.staffName ?? "N/A"}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateTime);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTime;
    }
  }

  Future<void> _submitData() async {
    if (selectedRemark == null) {
      showMessage(context, "Please select a remark");
      return;
    }
    if (selectedReason == null) {
      showMessage(context, "Please select a reason");
      return;
    }

    try {
      var data = {
        "ClientId": widget.clientId,
        "Remark": selectedRemark,
        "userId": Global_uid,
        "FinalRemark": selectedReason,
        "Notes": notesController.text,
        "ReminderDate": selectedReminderDate?.toIso8601String(),
      };

      await _client.postOverdueCallingRemark(data);
      showMessage(context, "Submitted Successfully!");
      Navigator.pop(context,);
    } catch (e) {
      showMessage(context, "Error submitting data");
    }
  }
}
