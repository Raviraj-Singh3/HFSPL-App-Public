import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/dde/dde_assigned_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:HFSPL/utils/date_utils.dart';
import 'package:intl/intl.dart';

class VerificationHistory extends StatefulWidget {
  const VerificationHistory({Key? key}) : super(key: key);

  @override
  State<VerificationHistory> createState() => _VerificationHistoryState();
}

class _VerificationHistoryState extends State<VerificationHistory> {
  List<DDEAssignedModel> completedVerifications = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    loadCompletedVerifications();
  }

  Future<void> loadCompletedVerifications() async {
    setState(() => isLoading = true);
    try {
      // For now, we'll use the same API but filter completed ones
      // In a real implementation, you might have a separate API for completed verifications
      final verifications = await _client.getAssignedVerificationList(int.parse(Global_uid));
      setState(() {
        // Filter completed verifications (this would be based on status in real implementation)
        completedVerifications = verifications.where((v) => v.ddeDate != null).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load verification history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedVerifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed verifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your completed verifications will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadCompletedVerifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: completedVerifications.length,
                    itemBuilder: (context, index) {
                      final verification = completedVerifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          verification.name ?? 'Unknown Member',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (verification.phone != null)
                                          Text(
                                            'Phone: ${verification.phone}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (verification.address != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Address: ${verification.address}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (verification.ddeDate != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Completed: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(verification.ddeDate!))}',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
