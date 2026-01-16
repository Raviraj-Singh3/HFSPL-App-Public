import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Additional/branch_wise_details.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final DioClient _client = DioClient();
  
  int numberOfDemand = 0;
  double sumOfDemand = 0.0;
  int numberOfCollection = 0;
  double sumOfCollection = 0.0;
  int totalActiveClients = 0;
  
  // OD Statistics from main API
  double overdueDemandAmount = 0.0;
  int overdueDemandClients = 0;
  
  // Additional OD Statistics from separate API
  double totalOsAmount = 0.0;
  int totalNewODs = 0;
  double newOdAmount = 0.0;
  int totalClosedODs = 0;
  double closedOdAmount = 0.0;
  
  bool isLoading = true;
  bool isLoadingOd = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchOdData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      context.loaderOverlay.show();
      setState(() {
        isLoading = true;
      });

      var response = await _client.getTodayDemandCollection(int.parse(Global_uid));

      setState(() {
        numberOfDemand = response['NumberOfDemand'] ?? 0;
        sumOfDemand = (response['SumOfDemand'] ?? 0.0).toDouble();
        numberOfCollection = response['NumberOfCollection'] ?? 0;
        sumOfCollection = (response['SumOfCollection'] ?? 0.0).toDouble();
        totalActiveClients = response['TotalActiveClients'] ?? 0;
        // Get OD data from the main API
        overdueDemandAmount = (response['OverdueDemandAmount'] ?? 0.0).toDouble();
        overdueDemandClients = response['OverdueDemandClients'] ?? 0;
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

  Future<void> _fetchOdData() async {
    try {
      setState(() {
        isLoadingOd = true;
      });

      var response = await _client.getTodayOdByUserId(int.parse(Global_uid));

      setState(() {
        // Additional OD details (new ODs, closed ODs, OS amount)
        // These metrics provide day-over-day comparison from OD files
        totalOsAmount = (response['TotalOsAmount'] ?? 0.0).toDouble();
        totalNewODs = response['TotalNewODs'] ?? 0;
        newOdAmount = (response['NewOdAmount'] ?? 0.0).toDouble();
        totalClosedODs = response['TotalClosedODs'] ?? 0;
        closedOdAmount = (response['ClosedOdAmount'] ?? 0.0).toDouble();
        isLoadingOd = false;
      });
    } catch (e) {
      // Silently fail for OD details API - not critical
      // The main OD metrics (amount & clients) come from the primary API
      setState(() {
        isLoadingOd = false;
        // Set to zero if API fails
        totalOsAmount = 0.0;
        totalNewODs = 0;
        newOdAmount = 0.0;
        totalClosedODs = 0;
        closedOdAmount = 0.0;
      });
      // Don't show error message as this is supplementary data
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _fetchDashboardData(),
      _fetchOdData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dashboard"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
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
                        Icons.dashboard,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Today's Overview",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Total Active Clients Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.blue.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(
                          Icons.people,
                          size: 48,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Active Clients",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            isLoading
                                ? const SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: CircularProgressIndicator(strokeWidth: 3),
                                  )
                                : Text(
                                    totalActiveClients.toString(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Demand Section
                const Text(
                  "Demand",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Number of Demands",
                        value: numberOfDemand.toString(),
                        icon: Icons.format_list_numbered,
                        color: Colors.orange,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: "Total Demand Amount",
                        value: "₹${_formatAmount(sumOfDemand)}",
                        icon: Icons.currency_rupee,
                        color: Colors.deepOrange,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Collection Section
                const Text(
                  "Collection",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Number of Collections",
                        value: numberOfCollection.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: "Total Collection Amount",
                        value: "₹${_formatAmount(sumOfCollection)}",
                        icon: Icons.account_balance_wallet,
                        color: Colors.teal,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Performance Summary",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        "Collection Rate",
                        _calculateCollectionRate(),
                        Icons.trending_up,
                        Colors.blue,
                        isLoading,
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        "Pending Amount",
                        "₹${_formatAmount(sumOfDemand - sumOfCollection)}",
                        Icons.pending_actions,
                        Colors.red,
                        isLoading,
                      ),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BranchWiseDetails(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("View Detailed Breakdown"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Overdue (OD) Section
                const Text(
                  "Overdue (OD) Overview",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // OD Members and Amount Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Total OD Members",
                        value: overdueDemandClients.toString(),
                        icon: Icons.people_outline,
                        color: Colors.red.shade700,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: "Total OD Amount",
                        value: "₹${_formatAmount(overdueDemandAmount)}",
                        icon: Icons.error_outline,
                        color: Colors.red.shade900,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // New ODs and Closed ODs Cards (from day-over-day comparison)
                if (!isLoadingOd && (totalNewODs > 0 || totalClosedODs > 0 || totalOsAmount > 0))
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "New ODs",
                              value: totalNewODs.toString(),
                              icon: Icons.add_alert,
                              color: Colors.orange.shade700,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: "Closed ODs",
                              value: totalClosedODs.toString(),
                              icon: Icons.check_circle_outline,
                              color: Colors.green.shade700,
                              isLoading: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Total OS Amount Card and OD Movement Summary (only if data available)
                if (!isLoadingOd && (totalOsAmount > 0 || newOdAmount > 0 || closedOdAmount > 0))
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Colors.red.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade100,
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Outstanding Amount",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "₹${_formatAmount(totalOsAmount)}",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "OD Movement Summary",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              "New OD Amount",
                              "₹${_formatAmount(newOdAmount)}",
                              Icons.trending_up,
                              Colors.orange.shade700,
                              false,
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              "Closed OD Amount",
                              "₹${_formatAmount(closedOdAmount)}",
                              Icons.trending_down,
                              Colors.green.shade700,
                              false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isLoading,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
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

  String _calculateCollectionRate() {
    if (sumOfDemand == 0) return "0%";
    double rate = (sumOfCollection / sumOfDemand) * 100;
    return "${rate.toStringAsFixed(2)}%";
  }
}
