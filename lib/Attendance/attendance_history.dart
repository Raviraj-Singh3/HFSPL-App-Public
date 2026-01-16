import 'package:HFSPL/network/responses/LeaveResponse/reporting_person_model.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/Attendance/attendance_history_card.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Attendance/attendance_model.dart';
import 'package:HFSPL/utils/globals.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  final DioClient _client = DioClient();
  bool isLoading = true;
  List<AttendanceModel> attendanceResponseHistory = [];
  List<ReportingPersonModel> reportingPersons = [];

  fetchAttendanceHistory() async {
    try {
      var response = await _client.getAttendanceHistory(int.parse(Global_uid));
      setState(() {
        attendanceResponseHistory = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
    Future<void> _fetchReportingPersons() async {
    try {
      var response = await _client.getReportingPerson(Global_uid);
      setState(() {
        reportingPersons = response;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendanceHistory();
    _fetchReportingPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceResponseHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No attendance history available",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: attendanceResponseHistory.length,
                  itemBuilder: (context, index) {
                    return AttendanceHistoryCard(
                        attendanceHistory: attendanceResponseHistory[index],
                        reportingPersons: reportingPersons,
                        );
                  },
                ),
    );
  }
}
