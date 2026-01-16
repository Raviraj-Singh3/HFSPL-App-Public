import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_history_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'leave_history_card.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  final DioClient _client = DioClient();
  late List<LeaveHistoryModel> leaveHistory;
  bool isLoading = true;

  _fetchLeaveHistory() async {
    try {
      var response = await _client.getLeaveHistory(Global_uid);
      setState(() {
        leaveHistory = response;
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

  @override
  void initState() {
    super.initState();
    _fetchLeaveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaveHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No leave history available",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: leaveHistory.length,
                  itemBuilder: (context, index) {
                    return LeaveHistoryCard(
                        leaveHistory: leaveHistory[index]);
                  },
                ),
    );
  }
}
