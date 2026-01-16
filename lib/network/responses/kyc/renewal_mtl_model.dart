class RenewalMtlResponse {
  final RenewalMtlDetails? details;
  final List<RenewalMtlOption>? options;
  final String? message;

  RenewalMtlResponse({
    this.details,
    this.options,
    this.message,
  });

  factory RenewalMtlResponse.fromJson(Map<String, dynamic> json) {
    return RenewalMtlResponse(
      details: json['details'] != null 
          ? RenewalMtlDetails.fromJson(json['details'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>)
              .map((e) => RenewalMtlOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      message: json['Message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.toJson(),
      'options': options?.map((e) => e.toJson()).toList(),
      'Message': message,
    };
  }
}

class RenewalMtlDetails {
  final int? nUid;
  final String? name;
  final String? loanNo;
  final int? snapId;
  final int? centerId;

  RenewalMtlDetails({
    this.nUid,
    this.name,
    this.loanNo,
    this.snapId,
    this.centerId,
  });

  factory RenewalMtlDetails.fromJson(Map<String, dynamic> json) {
    return RenewalMtlDetails(
      nUid: json['nUid'] as int?,
      name: json['Name'] as String?,
      loanNo: json['LoanNo'] as String?,
      snapId: json['SnapID'] as int?,
      centerId: json['CenterId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nUid': nUid,
      'Name': name,
      'LoanNo': loanNo,
      'SnapID': snapId,
      'CenterId': centerId,
    };
  }
}

class RenewalMtlOption {
  final int? type;
  final String? name;

  RenewalMtlOption({
    this.type,
    this.name,
  });

  factory RenewalMtlOption.fromJson(Map<String, dynamic> json) {
    return RenewalMtlOption(
      type: json['Type'] as int?,
      name: json['Name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Name': name,
    };
  }
} 