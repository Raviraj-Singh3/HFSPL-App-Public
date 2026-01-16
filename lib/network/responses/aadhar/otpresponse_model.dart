
class OTPResponseModel {
  final String? requestId;
  final Result? result;
  final int? statusCode;
  final ClientData? clientData;

  OTPResponseModel({
    this.requestId,
    this.result,
    this.statusCode,
    this.clientData,
  });

  // JSON Parsing
  factory OTPResponseModel.fromJson(Map<String, dynamic> json) {
    return OTPResponseModel(
      requestId: json['requestId'] as String?,
      result: json['result'] != null
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      statusCode: json['statusCode'] as int?,
      clientData: json['clientData'] != null
          ? ClientData.fromJson(json['clientData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'result': result?.toJson(),
        'statusCode': statusCode,
        'clientData': clientData?.toJson(),
      };
}

class Result {
  final String? message;

  Result({this.message});

  // JSON Parsing
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

class ClientData {
  final String? caseId;

  ClientData({this.caseId});

  // JSON Parsing
  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      caseId: json['caseId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
      };
}
