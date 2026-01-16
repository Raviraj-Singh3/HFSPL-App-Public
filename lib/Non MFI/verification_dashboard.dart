import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/utils/globals.dart';
import 'verification_eligible_members.dart';
import 'verification_assigned_list.dart';
import 'verification_history.dart';

class VerificationDashboard extends StatefulWidget {
  const VerificationDashboard({Key? key}) : super(key: key);

  @override
  State<VerificationDashboard> createState() => _VerificationDashboardState();
}

class _VerificationDashboardState extends State<VerificationDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NMFI Verification Dashboard')),
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
                      Icons.verified_user,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verification Process',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Branch Manager Verification for NMFI Loans',
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
                    'Eligible for Verification',
                    Icons.people,
                    Colors.blue,
                    'View members ready for verification',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationEligibleMembers(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'Assigned Verification',
                    Icons.schedule,
                    Colors.orange,
                    'View your assigned verifications',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationAssignedList(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'Verification History',
                    Icons.history,
                    Colors.green,
                    'View completed verifications',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationHistory(),
                      ),
                    ),
                  ),
                  
                  _buildActionCard(
                    context,
                    'Verification Stats',
                    Icons.analytics,
                    Colors.purple,
                    'View verification metrics',
                    () => _showVerificationStats(context),
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

  void _showVerificationStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Pending Verification', '5', Colors.orange),
            _buildStatRow('Verified This Week', '12', Colors.green),
            _buildStatRow('Rejected This Week', '2', Colors.red),
            _buildStatRow('Success Rate', '85%', Colors.blue),
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
