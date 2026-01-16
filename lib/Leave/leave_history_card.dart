import 'package:flutter/material.dart';
import '../network/responses/LeaveResponse/leave_history_model.dart';

class LeaveHistoryCard extends StatelessWidget {
  final LeaveHistoryModel leaveHistory;

  const LeaveHistoryCard({super.key, required this.leaveHistory,});

  @override
  Widget build(BuildContext context) {
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
                const Text("Applied Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(leaveHistory.formattedDate),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.event_available, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                const Text("Response Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(leaveHistory.responseDate),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...leaveHistory.leaves.map((leave) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        const Text("Leave Type: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(leave.leaveName),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 18, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        const Text("Leave Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(leave.leaveDate),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          leave.status == "Approved"
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 18,
                          color: leave.status == "Approved" ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(leave.status),
                      ],
                    ),
                    if (leave.comment.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.comment, size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            const Text("Comment: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(leave.comment,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 20, thickness: 1),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
