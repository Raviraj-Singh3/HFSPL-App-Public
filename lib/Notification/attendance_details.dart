import 'dart:convert';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/NotificationModel/attendance_update_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AttendanceDetails extends StatefulWidget {
  final String? guid;
  final int notiId;
  const AttendanceDetails({super.key, required this.guid, required this.notiId});

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  final DioClient _client = DioClient();
  AttendanceUpdateModel? attDetails;
  bool isLoading = true;
  bool showRejectBox = false;
  bool isApproved = false;
  final TextEditingController _commentController = TextEditingController();

  void _getAttendanceDetails() async {
    try {
      var response = await _client.getAttApprovalDetails(widget.guid!);
      setState(() {
        attDetails = response;
        isLoading = false;
      });
    } catch (e) {
      showMessage(context, "Error getting details");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _approveRequest() async {

    context.loaderOverlay.show();

    try {
      var request = {
        "guid": widget.guid!,
        "approvedBy": int.parse(Global_uid),
        "isApproved": isApproved,
        "comment": _commentController.text.isNotEmpty ? _commentController.text.trim() : "",
      };
      debugPrint("Approval Request: $request");
      await _client.postApproveAttendance(jsonEncode(request));
      showMessage(context, "${!isApproved ? "Rejected" : "Approved "} Successfully ✅");

      Navigator.pop(context, true); // Return to previous screen with success
    } catch (e) {
      showMessage(context, "$e");
    }
    context.loaderOverlay.hide();
  }

  void _rejectRequest() {
    setState(() {
      showRejectBox = true;
    });
  }

  void _submitReject() {
    if (_commentController.text.isEmpty) {
      showMessage(context, "Please enter a comment before rejecting ❗");
      return;
    }
    // API call to reject with comment
    showMessage(context, "Rejected with comment ❌");
  }

  @override
  void initState() {
    super.initState();
    _getAttendanceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attDetails == null
              ? const Center(child: Text("No data found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${attDetails!.staff?.name ?? ""}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              "Date: ${attDetails!.request?.date != null 
                                  ? DateFormat('dd-MMM-yyyy').format(attDetails!.request!.date!) 
                                  : ""}",
                            ),
                          const SizedBox(height: 8),
                          Text("Emp Code: ${attDetails!.staff?.empCode ?? ""}"),
                          const SizedBox(height: 8),
                          Text("Email: ${attDetails!.staff?.email ?? ""}"),
                          const SizedBox(height: 8),
                          Text("Reason: ${attDetails!.request?.reason ?? ""}"),
                          const SizedBox(height: 20),

                          TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                labelText: "Enter comment",
                                border: OutlineInputBorder(),
                              ),
                              // maxLines: 3,
                            ),
                          const SizedBox(height: 20),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () {
                                  isApproved = true;
                                  _approveRequest();
                                },
                                child: const Text("Approve"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  isApproved = false;
                                  _approveRequest();
                                },
                                child: const Text("Reject"),
                              ),
                            ],
                          ),

                          // Reject Comment Box
                          if (showRejectBox) ...[
                            const SizedBox(height: 20),
                            
                            const SizedBox(height: 12),
                            // Center(
                            //   child: ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.redAccent),
                            //     onPressed: () {
                            //       isApproved = false;
                            //       if (_commentController.text.isEmpty) {
                            //         showMessage(context, "Please enter a comment before rejecting ❗");
                            //         return;
                            //       }
                            //       _approveRequest();
                            //     },
                            //     child: const Text("Submit Reject"),
                            //   ),
                            // ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
