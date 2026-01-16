import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/demand_collection_model.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Additional/fe_wise_details.dart';

class BranchWiseDetails extends StatefulWidget {
  const BranchWiseDetails({super.key});

  @override
  State<BranchWiseDetails> createState() => _BranchWiseDetailsState();
}

class _BranchWiseDetailsState extends State<BranchWiseDetails> {
  final DioClient _client = DioClient();
  
  DemandCollectionModel? demandCollectionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBranchWiseData();
  }

  Future<void> _fetchBranchWiseData() async {
    try {
      context.loaderOverlay.show();
      setState(() {
        isLoading = true;
      });

      var response = await _client.getDemandCollection(int.parse(Global_uid));

      setState(() {
        demandCollectionData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showMessage(context, "Error: $e");
      }
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Branch-wise Details"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBranchWiseData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : demandCollectionData == null || 
              demandCollectionData!.branchWiseData == null ||
              demandCollectionData!.branchWiseData!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No branch data available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal.shade700, Colors.teal.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade200,
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.business,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Total Summary",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSummaryItem(
                                      "Demand",
                                      "₹${_formatAmount(demandCollectionData!.totalSumOfDemand ?? 0.0)}",
                                      "${demandCollectionData!.totalNumberOfDemand ?? 0}",
                                    ),
                                    Container(
                                      height: 60,
                                      width: 1,
                                      color: Colors.white30,
                                    ),
                                    _buildSummaryItem(
                                      "Collection",
                                      "₹${_formatAmount(demandCollectionData!.totalSumOfCollection ?? 0.0)}",
                                      "${demandCollectionData!.totalNumberOfCollection ?? 0}",
                                    ),
                                  ],
                                ),
                                if ((demandCollectionData!.totalOverdueDemandClients ?? 0) > 0) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade700.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Overdue: ${demandCollectionData!.totalOverdueDemandClients ?? 0} clients",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "(₹${_formatAmount(demandCollectionData!.totalOverdueDemandAmount ?? 0.0)})",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "All Branches (${demandCollectionData!.branchWiseData!.length})",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Branch Cards
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: demandCollectionData!.branchWiseData!.length,
                            itemBuilder: (context, index) {
                              final branch = demandCollectionData!.branchWiseData![index];
                              return _buildBranchCard(branch);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, String count) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$count entries",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(BranchData branch) {
    final collectionRate = (branch.sumOfDemand ?? 0) > 0
        ? ((branch.sumOfCollection ?? 0) / (branch.sumOfDemand ?? 1)) * 100
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeWiseDetails(
                branchId: branch.branchID,
                branchName: branch.branchName ?? "Branch",
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.branchName ?? "Unknown Branch",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: ${branch.branchID}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              
              const Divider(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "Demand",
                      "₹${_formatAmount(branch.sumOfDemand ?? 0.0)}",
                      "${branch.numberOfDemand ?? 0}",
                      Colors.orange,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      "Collection",
                      "₹${_formatAmount(branch.sumOfCollection ?? 0.0)}",
                      "${branch.numberOfCollection ?? 0}",
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.percent,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Collection Rate",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${collectionRate.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: collectionRate >= 80
                            ? Colors.green.shade700
                            : collectionRate >= 50
                                ? Colors.orange.shade700
                                : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // OD Information
              if ((branch.overdueDemandClients ?? 0) > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overdue: ${branch.overdueDemandClients ?? 0} clients",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Amount: ₹${_formatAmount(branch.overdueDemandAmount ?? 0.0)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String amount, String count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$count items",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)} Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)} L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(2)} K";
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
