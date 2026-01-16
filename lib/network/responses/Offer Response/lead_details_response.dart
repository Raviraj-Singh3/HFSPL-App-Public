class LeadDetailsResponse {
  final bool status;
  final String message;
  final List<LeadData> data;

  LeadDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LeadDetailsResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => LeadData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class LeadData {
  final int id;
  final int mobileNo;
  final String name;
  final String? email;
  final String leadId;
  final int misUserLoginId;
  final DateTime createdDate;
  final String panNo;
  final String pinCode;
  final String loanType;

  LeadData({
    required this.id,
    required this.mobileNo,
    required this.name,
     this.email,
    required this.leadId,
    required this.misUserLoginId,
    required this.createdDate,
    required this.panNo,
    required this.pinCode,
    required this.loanType,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) {
    return LeadData(
      id: json['Id'] as int? ?? 0,
      mobileNo: json['MobileNo'] as int? ?? 0,
      name: json['Name'] as String? ?? '',
      leadId: json['LeadId'] as String? ?? '',
      email: json['Email'] as String?,
      misUserLoginId: json['MisUserLoginId'] as int? ?? 0,
      createdDate: json['CreatedDate'] != null ? DateTime.parse(json['CreatedDate']) : DateTime.now(),
      panNo: json['PanNo'] as String? ?? '',
      pinCode: json['PinCode'] as String? ?? '',
      loanType: json['LoanType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'MobileNo': mobileNo,
      'Name': name,
      'Email': email,
      'LeadId': leadId,
      'MisUserLoginId': misUserLoginId,
      'CreatedDate': createdDate.toIso8601String(),
      'PanNo': panNo,
      'PinCode': pinCode,
      'LoanType': loanType,
    };
  }
}
