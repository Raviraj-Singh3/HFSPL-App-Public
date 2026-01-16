
class RejectionCriteriaModel {
  final String? requestId;
  final int? status;
  final String? error;
  final List<ErrorDetail>? errorList;

  RejectionCriteriaModel({
    this.requestId,
    this.status,
    this.error,
    this.errorList,
  });

  factory RejectionCriteriaModel.fromJson(Map<String, dynamic> json) {
    return RejectionCriteriaModel(
      requestId: json['requestId'] as String?,
      status: json['status'] as int?,
      error: json['error'] as String?,
      errorList: (json['errorList'] as List<dynamic>?)
          ?.map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status,
      'error': error,
      'errorList': errorList?.map((e) => e.toJson()).toList(),
    };
  }
}

class ErrorDetail {
  final String? field;
  final String? errorType;
  final String? validationParameter;

  ErrorDetail({
    this.field,
    this.errorType,
    this.validationParameter,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'] as String?,
      errorType: json['errorType'] as String?,
      validationParameter: json['validationParameter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'errorType': errorType,
      'validationParameter': validationParameter,
    };
  }
}
