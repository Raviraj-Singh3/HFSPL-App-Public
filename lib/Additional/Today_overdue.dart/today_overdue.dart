import 'package:HFSPL/Additional/Today_overdue.dart/update.dart';
import 'package:HFSPL/OD_Monetaring/call_screen.dart';
import 'package:HFSPL/utils/pick_date_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/network/responses/Today_overdue/today_overdue_response_model.dart';
import 'package:HFSPL/utils/get_felist_from_branchId.dart';
import 'package:HFSPL/utils/globals.dart';

class TodayOverdue extends StatefulWidget {
  const TodayOverdue({super.key});

  @override
  State<TodayOverdue> createState() => _TodayOverdueState();
}

class _TodayOverdueState extends State<TodayOverdue> {
  final DioClient _client = DioClient();

  List<BranchModel> branchList = [];
  List<ActiveFeModel> feList = [];
  List<TodayOverdueModel> todayOverdueData = [];

  int? selectedBranchId;
  int? selectedFeId;

  bool isLoadingBranches = true;
  bool isLoadingFEs = false;
  bool isLoadingOverdue = false;
  int? selectedGroupId;

  @override
  void initState() {
    super.initState();
    getBranches();
  }
  

  void getBranches() async {
    try {
      var response = await _client.getAllBranches(Global_uid);
      setState(() {
        branchList = response;
        isLoadingBranches = false;
      });
    } catch (e) {
      showMessage(context, "Error loading branches: $e");
    }
  }

  void getFeList() async {
    if (selectedBranchId == null) return;
    setState(() {
      isLoadingFEs = true;
      feList = [];
      selectedFeId = null;
    });

    try {
      var response = await getFeListFromBranchId(selectedBranchId!);
      setState(() {
        feList = response;
        isLoadingFEs = false;
      });
    } catch (e) {
      showMessage(context, "Error fetching FE list: $e");
    }
  }
  List<TodayOverdueModel> get filteredGroups {
  if (selectedGroupId == null) return todayOverdueData;
  return todayOverdueData.where((g) => g.groupId == selectedGroupId).toList();
  }

  void getToDayOverDue() async {
    if (selectedBranchId == null || selectedFeId == null) return;
    setState(() {
      isLoadingOverdue = true;
      todayOverdueData = [];
      selectedGroupId = null;
    });

    try {
      var response = await _client.getTodayOverdue(selectedBranchId!, selectedFeId!);
      setState(() {
        todayOverdueData = response;
        isLoadingOverdue = false;
      });
    } catch (e) {
      showMessage(context, "Error fetching overdue data: $e");
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: items,
          onChanged: isLoading ? null : onChanged,
        ),
      ],
    );
  }

  Widget _buildGroupCard(TodayOverdueModel group) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.groupName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text('Collection Time: ', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
                  Text(group.collectionTime ?? '', style: TextStyle(color: Colors.orange.shade800)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...group.members.map((member) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 20, thickness: 1.2),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${member.name} (${member.relativeName})',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text("${member.memberPhone1}", style: const TextStyle(color: Colors.black87)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _callNumber(member.memberPhone1.toString()),
                      ),
                    ],
                  ),
                  member.memberPhone2 != null && member.memberPhone2.toString().isNotEmpty
                      ? Row(
                          children: [
                            Icon(Icons.phone_android, color: Colors.green.shade700, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text("${member.memberPhone2}", style: const TextStyle(color: Colors.black87)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () => _callNumber(member.memberPhone2.toString()),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.payments, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Demand: ₹${member.demand?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_repeat, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Installment: ${member.installment}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        backgroundColor: Colors.blue.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),

                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(child: ElevatedButton(onPressed: ()=>updateBtn(member), child: const Text("Update"))),
                  const SizedBox(height: 4),
                ],
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Today's Overdue")),
    body: isLoadingBranches
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown<int>(
                  label: 'Select Branch',
                  value: selectedBranchId,
                  isLoading: false,
                  items: branchList.map((e) {
                    return DropdownMenuItem<int>(
                      value: e.bid,
                      child: Text(e.branchName ?? ""),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedBranchId = val;
                      selectedGroupId = null;
                    });
                    getFeList();
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown<int>(
                  label: 'Select Field Executive',
                  value: selectedFeId,
                  isLoading: isLoadingFEs,
                  items: feList.map((e) {
                    return DropdownMenuItem<int>(
                      value: e.feId,
                      child: Text(e.feName ?? ""),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedFeId = val;
                      selectedGroupId = null;
                    });
                    getToDayOverDue();
                  },
                ),
                const SizedBox(height: 20),
                if (!isLoadingOverdue && todayOverdueData.isNotEmpty) ...[
                  _buildGroupFilterDropdown(),
                  const SizedBox(height: 12),
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: filteredGroups.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildGroupCard(filteredGroups[index]);
                    },
                  ),
                ] else if (isLoadingOverdue)
                  const Center(child: CircularProgressIndicator())
                else
                  const Center(child: Text("No overdue data found.")),
              ],
            ),
          ),
  );
}
  Widget _buildGroupFilterDropdown() {
  return _buildDropdown<int>(
    label: 'Filter by Group',
    value: selectedGroupId,
    isLoading: false,
    items: todayOverdueData.map((group) {
      return DropdownMenuItem<int>(
        value: group.groupId,
        child: Text(group.groupName ?? ''),
      );
    }).toList()
      ..insert(
        0,
        const DropdownMenuItem<int>(
          value: null,
          child: Text('All Groups'),
        ),
      ),
    onChanged: (val) {
      setState(() {
        selectedGroupId = val;
      });
    },
  );
}
Future<void> _callNumber(String phoneNumber) async {
  if(phoneNumber.isEmpty || phoneNumber == "null"){
    showMessage(context, "Phone number is empty");
    return;
  }
  // print("phoneNumber: $phoneNumber");
  if (phoneNumber.isNotEmpty) {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == null || !res) {
      showMessage(context, "Failed to make the call");
    }
  }
}

 void updateBtn(Member member) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTodayOverdue(member: member)));
 }


}
