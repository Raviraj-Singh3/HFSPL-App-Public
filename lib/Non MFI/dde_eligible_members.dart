import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/dde/dde_eligible_member_model.dart';
import 'package:HFSPL/network/requests/dde_request_models.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/utils/date_utils.dart';

class DDEEligibleMembers extends StatefulWidget {
  const DDEEligibleMembers({Key? key}) : super(key: key);

  @override
  State<DDEEligibleMembers> createState() => _DDEEligibleMembersState();
}

class _DDEEligibleMembersState extends State<DDEEligibleMembers> {
  List<DDEEligibleMemberModel> eligibleMembers = [];
  List<int> selectedSnapshotIds = [];
  bool isLoading = true;
  final DioClient _client = DioClient();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadEligibleMembers();
  }

  Future<void> loadEligibleMembers() async {
    setState(() => isLoading = true);
    try {
      final members = await _client.getDDEEligibleMembers(int.parse(Global_uid));
      setState(() {
        eligibleMembers = members;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load eligible members: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> assignDDE() async {
    if (selectedSnapshotIds.isEmpty) {
      showMessage(context, 'Please select at least one member');
      return;
    }
    
    if (selectedDate == null) {
      showMessage(context, 'Please select a date for DDE');
      return;
    }

    context.loaderOverlay.show();
    try {
      final request = AssignDDERequest(
        snapshotIds: selectedSnapshotIds,
        ddeDate: selectedDate!.toIso8601String().split('T')[0],
        feId: int.parse(Global_uid),
      );
      
      await _client.assignDDE(request);
      
      context.loaderOverlay.hide();
      showMessage(context, 'DDE assigned successfully');
      
      // Refresh the list
      loadEligibleMembers();
      setState(() {
        selectedSnapshotIds.clear();
        selectedDate = null;
      });
    } catch (e) {
      context.loaderOverlay.hide();
      showMessage(context, 'Failed to assign DDE: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DDE Eligible Members')),
      body: Column(
        children: [
          // Selection Summary
          if (selectedSnapshotIds.isNotEmpty || selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selection Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('${selectedSnapshotIds.length} members selected'),
                    ],
                  ),
                  if (selectedDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          
          // Action Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: selectedDate == null ? 'Select Date' : 'Change Date',
                    onPressed: (dynamic _) => _selectDate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Assign DDE',
                    onPressed: (dynamic _) => assignDDE()
                  ),
                ),
              ],
            ),
          ),
          
          // Members List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : eligibleMembers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No eligible members found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'All members may have been assigned DDE already',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: eligibleMembers.length,
                        itemBuilder: (context, index) {
                          final member = eligibleMembers[index];
                          final isSelected = selectedSnapshotIds.contains(member.snapshotId);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedSnapshotIds.add(member.snapshotId!);
                                  } else {
                                    selectedSnapshotIds.remove(member.snapshotId);
                                  }
                                });
                              },
                              title: Text(
                                member.name ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (member.phone != null)
                                    Text('Phone: ${member.phone}'),
                                  if (member.address != null)
                                    Text('Address: ${member.address}'),
                                  if (member.eligibleAmount != null)
                                    Text(
                                      'Eligible Amount: ₹${member.eligibleAmount!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (member.crifCheckDate != null)
                                    Text(
                                      'CRIF Check: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(member.crifCheckDate!))}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: isSelected ? Colors.green : Colors.grey[300],
                                child: Icon(
                                  isSelected ? Icons.check : Icons.person,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
