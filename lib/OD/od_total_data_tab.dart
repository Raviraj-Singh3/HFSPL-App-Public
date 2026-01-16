import 'dart:async';

import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ODMODEL/od_total_model.dart';
import 'package:intl/intl.dart';

class OdTotalDataTab extends StatefulWidget {
  const OdTotalDataTab({super.key});

  @override
  State<OdTotalDataTab> createState() => _OdTotalDataTabState();
}

class _OdTotalDataTabState extends State<OdTotalDataTab> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  final DioClient _client = DioClient();
  OdTotalModel? odResponse;
  DateTime? selectedDate;
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  bool isFetching = false;
  DateTime? selectedFromDate;

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
      progressNotifier.value = 0.0; // Reset progress
    });

      // Start a timer to simulate progress increase
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (progressNotifier.value < 0.9) {
          progressNotifier.value += 0.05; // Increase by 5% every second
        } else {
          timer.cancel(); // Stop increasing if we reach ~90%
        }
      });

    try {

      var data = { 
            "InputDate": '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
            "InputFrom": '${selectedFromDate!.year}-${selectedFromDate!.month}-${selectedFromDate!.day}'
            };

      var response = await _client.getTotalOd(data);

    setState(() {
      odResponse = response;
      progressNotifier.value = 1.0; // Set progress to 100% when done
    });

    } catch (e) {

      showMessage(context, "Error: $e");

    }finally {
      setState(() {
        isFetching = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    int totalODChange = 0;

    if (odResponse != null) {
      totalODChange = (odResponse!.totalNewODs ?? 0) - (odResponse!.totalClosedODs ?? 0);
    }
    super.build(context);
    String formatMambers(dynamic value) {
        final formatter = NumberFormat.decimalPattern('en_IN'); // Indian format
        return formatter.format(value); // e.g. 23,86,352.5
      }
    String formatCurrency(dynamic value) {
      double inLacs = value / 100000;
      return '${inLacs.toStringAsFixed(2)} Lac';
    }
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Button
              Center(
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: (){
                        _pickDate(context);
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text("First Date"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: (){
                          _pickDateFrom(context);
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text("Second Date"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
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

              if (isFetching)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ValueListenableBuilder<double>(
                      valueListenable: progressNotifier,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            CircularProgressIndicator(
                              value: value, // Show Progress
                              strokeWidth: 6,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 10),
                            Text("${(value * 100).toInt()}% Completed",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        
              // Show OD Data
              if (odResponse != null && !isFetching)
                Column(
                  children: [
                    // Main OD Summary Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "OD Summary",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const Divider(thickness: 1),
        
                            _odInfoRow("Total Amount Payable :", "₹${formatCurrency(odResponse!.totalAmtPaybleOneDayBack!)}"),
                            _odInfoRow("Total Outstanding :", "₹${formatCurrency(odResponse!.totalOSOneDayBack)}"),
                            _odInfoRow("Total Members :", "${formatMambers(odResponse!.totalMembersOneDayBack)}"),
        
                            const SizedBox(height: 12),
                            const Divider(thickness: 1),
        
                            _odInfoRow("Total Amount Payable (On Second Date):", "₹${formatCurrency(odResponse!.totalAmtPaybleTwoDaysBack)}"),
                            _odInfoRow("Total Outstanding (On Second Date):", "₹${formatCurrency(odResponse!.totalOSTwoDaysBack)}"),
                            _odInfoRow("Total Members (On Second Date):", "${formatMambers(odResponse!.totalMembersTwoDaysBack!)}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
        
                    // New & Closed OD Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "New & Closed ODs",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _odStatCard("New ODs", odResponse?.totalNewODs?? 0, Colors.red),
                              _odStatCard("Closed ODs", odResponse?.totalClosedODs?? 0, Colors.green),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(thickness: 1),
        
                          // Increased or Decreased OD Status
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
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
      
  }
  Widget _odInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _odStatCard(String title, int count, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            "$count",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}