class BankAccModel {
  BankResult? result;
  String? requestId;
  String? statusCode;
  ClientData? clientData;

  BankAccModel({
    this.result,
    this.requestId,
    this.statusCode,
    this.clientData,
  });

  // Factory method to create a BankAccModel object from JSON
  factory BankAccModel.fromJson(Map<String, dynamic> json) {
    return BankAccModel(
      result: json['result'] != null
          ? BankResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      requestId: json['request_id'] as String?,
      statusCode: json['status-code'] as String?,
      clientData: json['clientData'] != null
          ? ClientData.fromJson(json['clientData'] as Map<String, dynamic>)
          : null,
    );
  }

  // Method to convert a BankAccModel object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'result': result?.toJson(),
      'request_id': requestId,
      'status-code': statusCode,
      'clientData': clientData?.toJson(),
    };
  }
}

class BankResult {
  String? accountNumber;
  String? ifsc;
  String? accountName;
  String? bankResponse;
  bool? bankTxnStatus;

  BankResult({
    this.accountNumber,
    this.ifsc,
    this.accountName,
    this.bankResponse,
    this.bankTxnStatus,
  });

  // Factory method to create a BankResult object from JSON
  factory BankResult.fromJson(Map<String, dynamic> json) {
    return BankResult(
      accountNumber: json['accountNumber'] as String?,
      ifsc: json['ifsc'] as String?,
      accountName: json['accountName'] as String?,
      bankResponse: json['bankResponse'] as String?,
      bankTxnStatus: json['bankTxnStatus'] as bool?,
    );
  }

  // Method to convert a BankResult object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'accountName': accountName,
      'bankResponse': bankResponse,
      'bankTxnStatus': bankTxnStatus,
    };
  }
}

class ClientData {
  String? caseId;

  ClientData({
    this.caseId,
  });

  // Factory method to create a ClientData object from JSON
  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      caseId: json['caseId'] as String?,
    );
  }

  // Method to convert a ClientData object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
    };
  }
}
