import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/dde/dde_assigned_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:HFSPL/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'dde_perform_session.dart';

class DDEAssignedList extends StatefulWidget {
  const DDEAssignedList({Key? key}) : super(key: key);

  @override
  State<DDEAssignedList> createState() => _DDEAssignedListState();
}

class _DDEAssignedListState extends State<DDEAssignedList> {
  List<DDEAssignedModel> assignedDDEs = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    loadAssignedDDEs();
  }

  Future<void> loadAssignedDDEs() async {
    setState(() => isLoading = true);
    try {
      final ddes = await _client.getAssignedDDEList(int.parse(Global_uid));
      setState(() {
        assignedDDEs = ddes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load assigned DDEs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned DDE Sessions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignedDDEs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No assigned DDE sessions',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for new assignments',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadAssignedDDEs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: assignedDDEs.length,
                    itemBuilder: (context, index) {
                      final dde = assignedDDEs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.school,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            dde.name ?? 'Unknown Member',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dde.phone != null)
                                Text('Phone: ${dde.phone}'),
                              if (dde.address != null)
                                Text('Address: ${dde.address}'),
                              if (dde.ddeDate != null)
                                Text(
                                  'Scheduled: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(dde.ddeDate!))}',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DDEPerformSession(
                                  ddeScheduleId: dde.ddeScheduleId!,
                                  memberName: dde.name!,
                                  scheduledDate: dde.ddeDate!,
                                ),
                              ),
                            ).then((_) {
                              // Refresh the list when returning from perform session
                              loadAssignedDDEs();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
