/// Enum representing different loan types in the NMFI system
/// 
/// Each loan type has a unique ID, title, and description that can be
/// used throughout the app for consistent labeling and configuration.
enum LoanType {
  personalLoan(
    1,
    'Personal Loan',
    'Individual Personal Loan Processing',
    'Complete KYC, DDE, and Verification for personal loans',
  ),
  lap(
    2,
    'Loan Against Property',
    'Property-backed Loan Processing',
    'Complete KYC, DDE, and Verification for loans against property',
  );

  const LoanType(this.id, this.title, this.subtitle, this.description);

  /// Unique identifier for the loan type
  final int id;
  
  /// Display title for the loan type
  final String title;
  
  /// Short subtitle/tagline
  final String subtitle;
  
  /// Detailed description
  final String description;

  /// Get LoanType from ID
  static LoanType fromId(int id) {
    return LoanType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => LoanType.personalLoan,
    );
  }

  /// Get display label with loan type
  String get dashboardTitle => '$title';
  
  /// Get KYC collection label
  String get kycLabel => 'KYC Collection - $title';
  
  /// Get DDE label
  String get ddeLabel => 'DDE Training - $title';
  
  /// Get verification label
  String get verificationLabel => 'Verification - $title';
}

