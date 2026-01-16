class LoanTenureModel {
  final int branchId;
  final List<LoanTenure> loanTenures;

  LoanTenureModel({
    required this.branchId,
    required this.loanTenures,
  });

  /// Factory method to create an instance from JSON
  factory LoanTenureModel.fromJson(Map<String, dynamic> json) {
    return LoanTenureModel(
      branchId: json['BranchId'] as int,
      loanTenures: (json['LoanTenures'] as List<dynamic>)
          .map((e) => LoanTenure.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'BranchId': branchId,
      'LoanTenures': loanTenures.map((e) => e.toJson()).toList(),
    };
  }
}

class LoanTenure {
  final String text;
  final int value;

  LoanTenure({
    required this.text,
    required this.value,
  });

  /// Factory method to create an instance from JSON
  factory LoanTenure.fromJson(Map<String, dynamic> json) {
    return LoanTenure(
      text: json['Text'] as String,
      value: json['Value'] as int,
    );
  }

  /// Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Text': text,
      'Value': value,
    };
  }
}
