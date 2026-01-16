import 'package:flutter/material.dart';
import 'package:HFSPL/OD/od_branchwise_tab.dart';
import 'package:HFSPL/OD/od_total_data_tab.dart';

class ODLandingPage extends StatelessWidget  {
  const ODLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: theme.primaryColor,
          title: const Text(
            'OD Page',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Colors.green.shade700,
                  //     Colors.green.shade900,
                  //   ],
                  // ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: 'Total Data'),
                  Tab(text: 'Branchwise Data'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            OdTotalDataTab(),
            BranchwiseDataTab(),
          ],
        ),
      ),
    );
  }
}
