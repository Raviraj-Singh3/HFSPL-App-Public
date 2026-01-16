import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/LeaveResponse/reporting_person_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/responses/Attendance/attendance_model.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AttendanceHistoryCard extends StatefulWidget {
  final AttendanceModel attendanceHistory;
  final List<ReportingPersonModel> reportingPersons;
  const AttendanceHistoryCard({super.key, required this.attendanceHistory,required this.reportingPersons,});

  @override
  State<AttendanceHistoryCard> createState() => _AttendanceHistoryCardState();
}

class _AttendanceHistoryCardState extends State<AttendanceHistoryCard> {
  bool showUpdateForm = false;
  final DioClient _client = DioClient();
  final TextEditingController _reasonController = TextEditingController();
  String? selectedPerson;
   List<ReportingPersonModel> reportingPerson = [];
     int? selectedReportingPerson;

  final List<String> approvers = ["Manager", "HR", "Admin"]; // sample list

   @override
  void initState() {
    super.initState();
    _reasonController.addListener(() {
      setState(() {}); // rebuild when reason text changes
    });
  }
   @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceHistory = widget.attendanceHistory;
    final reportingPerson = widget.reportingPersons;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                const Text("Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(attendanceHistory.dateTime!),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.login, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                const Text("Punch-In: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(attendanceHistory.pTime!),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                const SizedBox(width: 6),
                const Text("Punch-Out: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  attendanceHistory.oTime!,
                  style: TextStyle(
                    color: attendanceHistory.oTime == "Not Marked"
                        ? Colors.orange
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Main row (status present/absent only)
              Row(
                children: [
                  Icon(
                    attendanceHistory.aStatus! ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: attendanceHistory.aStatus! ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  const Text("Status: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    attendanceHistory.aStatus! ? "Present" : "Absent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          attendanceHistory.aStatus! ? Colors.green : Colors.red,
                    ),
                  ),
                  const Spacer(),

                  // ✅ Show button only when absent & no request
                  if (!(attendanceHistory.aStatus! && attendanceHistory.attReq == null))
                    if (attendanceHistory.attReq == null)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showUpdateForm = !showUpdateForm;
                          });
                        },
                        child: Text(showUpdateForm ? "Cancel" : "Request Update"),
                      ),
                ],
              ),

              // ✅ Below the row: Request Info (if exists)
              if (attendanceHistory.attReq != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.info, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    const Text("Attendance Request: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      attendanceHistory.attReq!.status ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: attendanceHistory.attReq!.status == "Pending"
                            ? Colors.orange
                            : attendanceHistory.attReq!.status == "Approved"
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),

                if (attendanceHistory.attReq!.comment != null &&
                    attendanceHistory.attReq!.comment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0,), // dent
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text("Comment: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            attendanceHistory.attReq!.comment!,
                            style: const TextStyle(color: Colors.black87),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),

            // Expandable form section
            if (showUpdateForm) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: "Reason for Absence",
                  border: OutlineInputBorder(),
                ),
                // maxLines: 2,
              ),
              const SizedBox(height: 12),
              if (reportingPerson.isNotEmpty)
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Reporting Person',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedReportingPerson,
                    items: reportingPerson.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReportingPerson = value;
                      });
                    },
                  ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: selectedReportingPerson == null || _reasonController.text.trim().isEmpty ? null : () {
                    requestAttendanceUpdate(_reasonController.text.trim(), selectedReportingPerson, attendanceHistory.dateTime!);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text("Submit"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
  void requestAttendanceUpdate(String reason, int? approverId, String date) async {

    final oldAttReq = widget.attendanceHistory.attReq;

    context.loaderOverlay.show();

    try {
      var data = {"reason": reason, "approverId": approverId, "date": date, "staffId": Global_uid};
      var response = await _client.requestAttendanceUpdate(data);
      showMessage(context, "Request submitted successfully.");
      setState(() {
        widget.attendanceHistory.attReq = AttendanceRequest(
        status: "Pending",
        comment: "",
      );
      showUpdateForm = false;
      _reasonController.clear();
      selectedReportingPerson = null;
      });
    } catch (e) {
      // setState(() {
      //   widget.attendanceHistory.attReq = oldAttReq;
      // });
      showMessage(context, "$e");
    }

    context.loaderOverlay.hide();

  }
  
}
