import 'package:flutter/foundation.dart';

@immutable
class PostClientAccountDetailsRequest {
  final String? bankAccNo;
  final String? bankName;
  final String? branchName;
  final int? clientId;
  final String? clientName;
  final int? eligibleAmt;
  final int? hospicashStatus;
  final String? ifsc;
  final String? loanPurpose;
  final double? selectedProduct;
  final int? selectedTenure;
  final int? uid;
  final int? updateBy;

  const PostClientAccountDetailsRequest({
    this.bankAccNo = "",
    this.bankName = "",
    this.branchName = "",
    this.clientId = 0,
    this.clientName = "",
    this.eligibleAmt = 0,
    this.hospicashStatus = 0,
    this.ifsc = "",
    this.loanPurpose = "",
    this.selectedProduct = 0.0,
    this.selectedTenure = 0,
    this.uid = 0,
    this.updateBy = 0,
  });

  // Factory constructor for creating an instance from JSON
  factory PostClientAccountDetailsRequest.fromJson(Map<String, dynamic> json) {
    return PostClientAccountDetailsRequest(
      bankAccNo: json['BankAccNo'] as String?,
      bankName: json['BankName'] as String?,
      branchName: json['BranchName'] as String?,
      clientId: json['ClientId'] as int?,
      clientName: json['ClientName'] as String?,
      eligibleAmt: json['EligibleAmt'] as int?,
      hospicashStatus: json['HospicashStatus'] as int?,
      ifsc: json['Ifsc'] as String?,
      loanPurpose: json['LoanPurpose'] as String?,
      selectedProduct: (json['SelectedProduct'] as num?)?.toDouble(),
      selectedTenure: json['SelectedTenure'] as int?,
      uid: json['Uid'] as int?,
      updateBy: json['UpdateBy'] as int?,
    );
  }

  // Method for converting an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'BankAccNo': bankAccNo,
      'BankName': bankName,
      'BranchName': branchName,
      'ClientId': clientId,
      'ClientName': clientName,
      'EligibleAmt': eligibleAmt,
      'HospicashStatus': hospicashStatus,
      'Ifsc': ifsc,
      'LoanPurpose': loanPurpose,
      'SelectedProduct': selectedProduct,
      'SelectedTenure': selectedTenure,
      'Uid': uid,
      'UpdateBy': updateBy,
    };
  }

  // Copy with method for immutability
  PostClientAccountDetailsRequest copyWith({
    String? bankAccNo,
    String? bankName,
    String? branchName,
    int? clientId,
    String? clientName,
    int? eligibleAmt,
    int? hospicashStatus,
    String? ifsc,
    String? loanPurpose,
    double? selectedProduct,
    int? selectedTenure,
    int? uid,
    int? updateBy,
  }) {
    return PostClientAccountDetailsRequest(
      bankAccNo: bankAccNo ?? this.bankAccNo,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      eligibleAmt: eligibleAmt ?? this.eligibleAmt,
      hospicashStatus: hospicashStatus ?? this.hospicashStatus,
      ifsc: ifsc ?? this.ifsc,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedTenure: selectedTenure ?? this.selectedTenure,
      uid: uid ?? this.uid,
      updateBy: updateBy ?? this.updateBy,
    );
  }
}
