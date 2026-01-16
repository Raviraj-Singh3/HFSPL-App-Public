import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/dde/dde_assigned_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:HFSPL/utils/date_utils.dart';
import 'package:intl/intl.dart';

class DDEHistory extends StatefulWidget {
  const DDEHistory({Key? key}) : super(key: key);

  @override
  State<DDEHistory> createState() => _DDEHistoryState();
}

class _DDEHistoryState extends State<DDEHistory> {
  List<DDEAssignedModel> completedDDEs = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    loadCompletedDDEs();
  }

  Future<void> loadCompletedDDEs() async {
    setState(() => isLoading = true);
    try {
      // For now, we'll use the same API but filter completed ones
      // In a real implementation, you might have a separate API for completed DDEs
      final ddes = await _client.getAssignedDDEList(int.parse(Global_uid));
      setState(() {
        // Filter completed DDEs (this would be based on status in real implementation)
        completedDDEs = ddes.where((dde) => dde.ddeDate != null).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load DDE history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DDE History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedDDEs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed DDE sessions',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your completed DDE sessions will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadCompletedDDEs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: completedDDEs.length,
                    itemBuilder: (context, index) {
                      final dde = completedDDEs[index];
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
                                          dde.name ?? 'Unknown Member',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (dde.phone != null)
                                          Text(
                                            'Phone: ${dde.phone}',
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
                                      'Completed',
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
                              if (dde.address != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Address: ${dde.address}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (dde.ddeDate != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Completed: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(dde.ddeDate!))}',
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
