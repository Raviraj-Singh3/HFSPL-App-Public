import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/dde/dde_assigned_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:HFSPL/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'verification_perform_session.dart';

class VerificationAssignedList extends StatefulWidget {
  const VerificationAssignedList({Key? key}) : super(key: key);

  @override
  State<VerificationAssignedList> createState() => _VerificationAssignedListState();
}

class _VerificationAssignedListState extends State<VerificationAssignedList> {
  List<DDEAssignedModel> assignedVerifications = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    loadAssignedVerifications();
  }

  Future<void> loadAssignedVerifications() async {
    setState(() => isLoading = true);
    try {
      final verifications = await _client.getAssignedVerificationList(int.parse(Global_uid));
      setState(() {
        assignedVerifications = verifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load assigned verifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Verifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignedVerifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No assigned verifications',
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
                  onRefresh: loadAssignedVerifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: assignedVerifications.length,
                    itemBuilder: (context, index) {
                      final verification = assignedVerifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.verified_user,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            verification.name ?? 'Unknown Member',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (verification.phone != null)
                                Text('Phone: ${verification.phone}'),
                              if (verification.address != null)
                                Text('Address: ${verification.address}'),
                              if (verification.ddeDate != null)
                                Text(
                                  'Scheduled: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(verification.ddeDate!))}',
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
                                builder: (context) => VerificationPerformSession(
                                  ddeScheduleId: verification.ddeScheduleId!,
                                  memberName: verification.name!,
                                  scheduledDate: verification.ddeDate,
                                ),
                              ),
                            ).then((_) {
                              // Refresh the list when returning from perform session
                              loadAssignedVerifications();
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
