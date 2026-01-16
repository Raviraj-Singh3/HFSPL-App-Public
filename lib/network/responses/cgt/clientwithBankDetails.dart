import 'package:flutter/foundation.dart';

@immutable
class ClientAccountDetailsResponse {
  final Client? client;
  final List<String>? loanpurpose;
  final List<double>? products;

  const ClientAccountDetailsResponse({
    this.client,
    this.loanpurpose,
    this.products,
  });

  factory ClientAccountDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ClientAccountDetailsResponse(
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      loanpurpose: (json['loanpurpose'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => (item as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client?.toJson(),
      'loanpurpose': loanpurpose,
      'products': products,
    };
  }
}

@immutable
class Client {
  final String? bankAccNo;
  final String? bankBranchName;
  final String? bankIfscCode;
  final String? bankName;
  final double? eligibleAmt;
  final int? hospicashStatus;
  final int? id;
  final bool? isPPIfilled;
  final String? loanPurpose;
  final String? name;
  final String? passbookFile;
  final String? relative;
  final double? selectedProduct;
  final int? uID;

  const Client({
    this.bankAccNo,
    this.bankBranchName,
    this.bankIfscCode,
    this.bankName,
    this.eligibleAmt,
    this.hospicashStatus,
    this.id,
    this.isPPIfilled,
    this.loanPurpose,
    this.name,
    this.passbookFile,
    this.relative,
    this.selectedProduct,
    this.uID,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      bankAccNo: json['bank_acc_no'] as String?,
      bankBranchName: json['bank_branch_name'] as String?,
      bankIfscCode: json['bank_ifsc_code'] as String?,
      bankName: json['bank_name'] as String?,
      eligibleAmt: (json['ELIGIBLE_AMT'] as num?)?.toDouble(),
      hospicashStatus: json['HospicashStatus'] as int?,
      id: json['id'] as int?,
      isPPIfilled: json['IsPPIfilled'] as bool?,
      loanPurpose: json['LoanPurpose'] as String?,
      name: json['Name'] as String?,
      passbookFile: json['PassbookFile'] as String?,
      relative: json['Relative'] as String?,
      selectedProduct: (json['SelectedProduct'] as num?)?.toDouble(),
      uID: json['UID'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_acc_no': bankAccNo,
      'bank_branch_name': bankBranchName,
      'bank_ifsc_code': bankIfscCode,
      'bank_name': bankName,
      'ELIGIBLE_AMT': eligibleAmt,
      'HospicashStatus': hospicashStatus,
      'id': id,
      'IsPPIfilled': isPPIfilled,
      'LoanPurpose': loanPurpose,
      'Name': name,
      'PassbookFile': passbookFile,
      'Relative': relative,
      'SelectedProduct': selectedProduct,
      'UID': uID,
    };
  }
}
