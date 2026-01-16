import 'dart:async';

import 'package:HFSPL/network/responses/OD/od_branchwise_response.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:intl/intl.dart';

class BranchwiseDataTab extends StatefulWidget {
  const BranchwiseDataTab({super.key});

  @override
  State<BranchwiseDataTab> createState() => _BranchwiseDataTabState();
}

class _BranchwiseDataTabState extends State<BranchwiseDataTab> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  final DioClient _client = DioClient();
  List<ODBranchWiseResponse> odBranchWiseResponse = [];
  List<ODBranchWiseResponse> filteredResponse = [];
  DateTime? selectedDate;
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  bool isFetching = false;
  DateTime? selectedFromDate;
  int? selectedFunderId;
  List<Map<String, dynamic>> uniqueFunders = [];

  @override
  void initState() {
    super.initState();
    filteredResponse = odBranchWiseResponse;
  }

  void _extractUniqueFunders() {
    Set<int> funderIds = {};
    Map<int, String> funderNames = {};

    for (var region in odBranchWiseResponse) {
      for (var area in region.areas) {
        for (var branch in area.branches) {
          funderIds.add(branch.funderId);
          funderNames[branch.funderId] = branch.funderName;
        }
      }
    }

    uniqueFunders = funderIds.map((id) => {
      'id': id,
      'name': funderNames[id] ?? 'Unknown Funder'
    }).toList();

    // Sort funders by ID for consistent display
    uniqueFunders.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
  }

  void _filterByFunder(int? funderId) {
    setState(() {
      selectedFunderId = funderId;
      if (funderId == null) {
        filteredResponse = odBranchWiseResponse;
        return;
      }

      filteredResponse = odBranchWiseResponse.map((region) {
        // Create a new list of areas with filtered branches
        var newAreas = region.areas.map((area) {
          // Filter branches by funder ID
          var filteredBranches = area.branches.where((branch) => 
            branch.funderId == funderId
          ).toList();

          // Create a new area with filtered branches
          return ODArea(
            areaId: area.areaId,
            areaName: area.areaName,
            branches: filteredBranches,
            totalNewOds: filteredBranches.fold(0, (sum, branch) => sum + branch.totalNewOds),
            totalClosedOds: filteredBranches.fold(0, (sum, branch) => sum + branch.totalClosedOds),
          );
        }).where((area) => area.branches.isNotEmpty).toList();

        // Create a new region with filtered areas
        return ODBranchWiseResponse(
          regionId: region.regionId,
          regionName: region.regionName,
          areas: newAreas,
          totalNewOds: newAreas.fold(0, (sum, area) => sum + area.totalNewOds),
          totalClosedOds: newAreas.fold(0, (sum, area) => sum + area.totalClosedOds),
        );
      }).where((region) => region.areas.isNotEmpty).toList();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    selectedFromDate = null;
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(days: 1)); // Get one day back
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: yesterday,
      firstDate: DateTime(2024, 5, 2),
      lastDate: yesterday,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _pickDateFrom(context);
    }
  }

  Future<void> _pickDateFrom(BuildContext context) async {

    if(selectedDate == null)return;
    // final DateTime now = DateTime.now();
    final DateTime dayAfterYesterday = selectedDate!.subtract(Duration(days: 1)); // Get one day back
    final DateTime? picked = await showDatePicker(
      helpText: 'Select Second Date',
      context: context,
      initialDate: dayAfterYesterday,
      firstDate: DateTime(2024, 5, 1),
      lastDate: dayAfterYesterday,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedFromDate = picked;
      });
    }
    _fetch();
  }

  _fetch() async {
    if(selectedDate == null || selectedFromDate == null){
      showMessage(context, "Select Both Dates");
      return;
    }
    
    setState(() {
      isFetching = true;
      progressNotifier.value = 0.0;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (progressNotifier.value < 0.9) {
        progressNotifier.value += 0.05;
      } else {
        timer.cancel();
      }
    });

    try {
      var data = { 
        "InputDate": '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
        "InputFrom": '${selectedFromDate!.year}-${selectedFromDate!.month}-${selectedFromDate!.day}'
      };

      var response = await _client.getTotalOdBranchWise(data);

      setState(() {
        odBranchWiseResponse = response;
        filteredResponse = response;
        _extractUniqueFunders();
        progressNotifier.value = 1.0;
      });

    } catch (e) {
      showMessage(context, "Error: $e");
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  super.build(context);
  final theme = Theme.of(context);

  return SingleChildScrollView(
    padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
    child: Column(
      children: [
        // Date pickers (same as before)...
        Row(
          children: [
            Expanded(child: _gradientDateButton("First Date", () => _pickDate(context))),
            const SizedBox(width: 12),
            Expanded(child: _gradientDateButton("Second Date", () => _pickDateFrom(context))),
          ],
        ),
        const SizedBox(height: 16),
        // Show Selected Date
              if (selectedDate != null)
                Center(
                  child: Text(
                    "First Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              const SizedBox(height: 16),

              if (selectedFromDate != null)
                Center(
                  child: Text(
                    "Second Date: ${selectedFromDate!.day}/${selectedFromDate!.month}/${selectedFromDate!.year}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              const SizedBox(height: 16),
        if (uniqueFunders.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal),
            ),
            child: DropdownButton<int?>(
              isExpanded: true,
              value: selectedFunderId,
              hint: const Text('Select Funder'),
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Funders'),
                ),
                ...uniqueFunders.map((funder) => DropdownMenuItem<int?>(
                  value: funder['id'] as int,
                  child: Text(funder['name'] as String),
                )).toList(),
              ],
              onChanged: (value) => _filterByFunder(value),
            ),
          ),
        const SizedBox(height: 16),
        if (isFetching)
          _buildProgress(),
        if (!isFetching && filteredResponse.isNotEmpty)
          ...filteredResponse.map((region) {
  return ExpansionTile(
    title: Text(
      "${region.regionName} (New ODs: ${region.totalNewOds}, Closed ODs: ${region.totalClosedOds})",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
    ),
    children: region.areas.map((area) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ExpansionTile(
          title: Text(
            "Area: ${area.areaName} (New ODs: ${area.totalNewOds}, Closed ODs: ${area.totalClosedOds})",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          children: area.branches.map((branch) {
            final amtDelta = branch.totalAmtPayableTwoDaysBack - branch.totalAmtPayableOneDayBack;
            final osDelta  = branch.totalOsTwoDaysBack - branch.totalOsOneDayBack;
            final memDelta = branch.totalMembersTwoDaysBack - branch.totalMembersOneDayBack;
            int totalODChange = 0;
              totalODChange = (branch.totalNewOds ?? 0) - (branch.totalClosedOds ?? 0);
            if(branch.branchId == 3 || branch.branchId == 12){
              print("amtDelta: $amtDelta, osDelta: $osDelta, memDelta: $memDelta, totalODChange: $totalODChange");
            }
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.branchName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("New ODs: ${branch.totalNewOds}", style: const TextStyle(color: Colors.red)),
                        const SizedBox(width: 16),
                        Text("Closed ODs: ${branch.totalClosedOds}", style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                totalODChange > 0 ? "OD Increased by " : "OD Decreased by ",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "${totalODChange.abs()}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: totalODChange > 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                    const Divider(height: 20),
                    _comparisonRow("Amount Payable", 
                        branch.totalAmtPayableTwoDaysBack, branch.totalAmtPayableOneDayBack, amtDelta),
                    const SizedBox(height: 8),
                    _comparisonRow("Outstanding", 
                        branch.totalOsTwoDaysBack, branch.totalOsOneDayBack, osDelta),
                    const SizedBox(height: 8),
                    _comparisonRow("Members",
                        branch.totalMembersTwoDaysBack, branch.totalMembersOneDayBack, memDelta),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }).toList(),
  );
}).toList(),
      ],
    ),
  );
}
// Gradient-styled date picker button
Widget _gradientDateButton(String label, VoidCallback onTap) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    ),
  );
}

// Progress indicator builder
Widget _buildProgress() {
  return Column(
    children: [
      ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (_, value, __) => CircularProgressIndicator(
          value: value,
          strokeWidth: 6,
          valueColor: const AlwaysStoppedAnimation(Colors.green),
        ),
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (_, value, __) => Text("${(value * 100).toInt()}% completed"),
      ),
      const SizedBox(height: 16),
    ],
  );
}
String formatCurrency(num value) {
  double inLacs = value / 100000;
  return '${inLacs.toStringAsFixed(2)} Lac';
}
// Single comparison row widget
Widget _comparisonRow(String label, num oldValue, num newValue, num delta) {
  final deltaColor = delta >= 0 ? Colors.green : Colors.red;
  final deltaSign = delta >= 0 ? "" : "";
  final deltaValue = formatCurrency(delta.abs());
  return Row(
    children: [
      Expanded(flex: 3, child: Text(label)),
      Expanded(flex: 2, child: Text(label != "Members" ? "₹${formatCurrency(oldValue)}" : "$oldValue", textAlign: TextAlign.center)),
      Expanded(flex: 2, child: Text(label != "Members" ? "₹${formatCurrency(newValue)}" : "$newValue", textAlign: TextAlign.center)),
      Expanded(
        flex: 2,
        child: Text(label != "Members" ? "$deltaSign₹$deltaValue" : "$deltaSign${delta.abs()}",
          textAlign: TextAlign.end,
          style: TextStyle(color: deltaColor, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
}