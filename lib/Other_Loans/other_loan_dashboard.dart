import 'package:HFSPL/Other_Loans/gold_loan.dart';
import 'package:HFSPL/Other_Loans/mobile_check.dart';
import 'package:HFSPL/Other_Loans/housing_loan_page.dart';
import 'package:HFSPL/Non MFI/nmfi_dashboard.dart';
import 'package:HFSPL/models/loan_type.dart';
import 'package:flutter/material.dart';

class OtherLoanDashboard extends StatelessWidget {
  const OtherLoanDashboard({super.key});

  Widget _buildLoanCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Dashboard'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Loan Options',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choose from our range of customized loan products',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLoanCard(
                title: 'NMFI - Personal Loan',
                description: 'Individual personal loan processing with KYC, DDE, and Verification',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NMFIDashboard(loanType: LoanType.personalLoan)),
                  );
                },
              ),
              _buildLoanCard(
                title: 'LAP - Loan Against Property',
                description: 'Property-backed loan processing with KYC, DDE, and Verification',
                icon: Icons.home_work,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NMFIDashboard(loanType: LoanType.lap)),
                  );
                },
              ),
              _buildLoanCard(
                title: 'Personal/Business Loan',
                description: 'Get quick loans for personal or business needs with minimal documentation',
                icon: Icons.account_balance_wallet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MobileCheck()),
                ),
              ),
              _buildLoanCard(
                title: 'Gold Loan',
                description: 'Convert your gold into instant cash with best market rates',
                icon: Icons.monetization_on,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoldLoan()),
                ),
              ),
              _buildLoanCard(
                title: 'Housing Loan',
                description: 'Apply for a housing loan with competitive rates and flexible terms',
                icon: Icons.house,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HousingLoanPage()),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All loans are subject to eligibility criteria and documentation requirements',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

}