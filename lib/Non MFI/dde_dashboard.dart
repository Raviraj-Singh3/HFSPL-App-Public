import 'package:flutter/material.dart';
import 'package:HFSPL/utils/globals.dart';
import 'dde_eligible_members.dart';
import 'dde_assigned_list.dart';
import 'dde_history.dart';

class DDEDashboard extends StatefulWidget {
  const DDEDashboard({Key? key}) : super(key: key);

  @override
  State<DDEDashboard> createState() => _DDEDashboardState();
}

class _DDEDashboardState extends State<DDEDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NMFI DDE Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detailed Data Entry (DDE)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Individual Loan Training Process',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    'Eligible Members',
                    Icons.people,
                    Colors.blue,
                    'View members ready for DDE training',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DDEEligibleMembers(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'Assigned DDE',
                    Icons.schedule,
                    Colors.orange,
                    'View your assigned DDE sessions',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DDEAssignedList(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'DDE History',
                    Icons.history,
                    Colors.green,
                    'View completed DDE sessions',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DDEHistory(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'Quick Stats',
                    Icons.analytics,
                    Colors.purple,
                    'View DDE performance metrics',
                    () => _showQuickStats(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DDE Quick Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Eligible', '12', Colors.blue),
            _buildStatRow('Assigned Today', '3', Colors.orange),
            _buildStatRow('Completed This Week', '8', Colors.green),
            _buildStatRow('Pending Review', '2', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
