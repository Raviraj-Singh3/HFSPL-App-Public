import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/fe_wise_demand_collection_model.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FeWiseDetails extends StatefulWidget {
  final int? branchId;
  final String branchName;

  const FeWiseDetails({
    super.key,
    this.branchId,
    this.branchName = "All Branches",
  });

  @override
  State<FeWiseDetails> createState() => _FeWiseDetailsState();
}

class _FeWiseDetailsState extends State<FeWiseDetails> {
  final DioClient _client = DioClient();
  
  FeWiseDemandCollectionModel? feWiseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeWiseData();
  }

  Future<void> _fetchFeWiseData() async {
    try {
      context.loaderOverlay.show();
      setState(() {
        isLoading = true;
      });

      var response = await _client.getFeWiseDemandCollection(
        int.parse(Global_uid),
        branchId: widget.branchId,
      );

      setState(() {
        feWiseData = response;
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
        title: Text("FE Details - ${widget.branchName}"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFeWiseData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : feWiseData == null || 
              feWiseData!.feWiseData == null ||
              feWiseData!.feWiseData!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No FE data available",
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
                                colors: [Colors.indigo.shade700, Colors.indigo.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.shade200,
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Field Executives",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Total: ${feWiseData!.feWiseData!.length} FEs",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "All Field Executives (${feWiseData!.feWiseData!.length})",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // FE Cards
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: feWiseData!.feWiseData!.length,
                            itemBuilder: (context, index) {
                              final fe = feWiseData!.feWiseData![index];
                              return _buildFeCard(fe);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildFeCard(FeData fe) {
    final collectionRate = (fe.sumOfDemand ?? 0) > 0
        ? ((fe.sumOfCollection ?? 0) / (fe.sumOfDemand ?? 1)) * 100
        : 0.0;

    Color performanceColor = collectionRate >= 80
        ? Colors.green.shade700
        : collectionRate >= 50
            ? Colors.orange.shade700
            : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FE Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.indigo.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fe.feName ?? "Unknown FE",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "ID: ${fe.feId}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fe.branchName ?? "Unknown Branch",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Performance Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: performanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: performanceColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "${collectionRate.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    "Demand",
                    "₹${_formatAmount(fe.sumOfDemand ?? 0.0)}",
                    "${fe.numberOfDemand ?? 0} items",
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox(
                    "Collection",
                    "₹${_formatAmount(fe.sumOfCollection ?? 0.0)}",
                    "${fe.numberOfCollection ?? 0} items",
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    "Active Clients",
                    "${fe.totalActiveClients ?? 0}",
                    "Total clients",
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox(
                    "Pending",
                    "₹${_formatAmount((fe.sumOfDemand ?? 0) - (fe.sumOfCollection ?? 0))}",
                    "Balance",
                    Icons.pending_actions,
                    Colors.red,
                  ),
                ),
              ],
            ),

            // OD Information
            if ((fe.overdueDemandClients ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.shade200, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 24,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overdue Clients",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${fe.overdueDemandClients ?? 0} clients",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.red.shade200,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "OD Amount",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${_formatAmount(fe.overdueDemandAmount ?? 0.0)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
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
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
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
