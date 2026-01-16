class VerifyOtpResponse {
  final int? id;
  final int? userId;
  final int? otpNumber;
  final String? tokenKey;
  final String? createdDate;
  final bool? isActive;
  final int? otpCounter;
  final String? name;
  final String? designationName;
  final int? designationId;

  VerifyOtpResponse({
    this.id,
    this.userId,
    this.otpNumber,
    this.tokenKey,
    this.createdDate,
    this.isActive,
    this.otpCounter,
    this.name,
    this.designationName,
    this.designationId,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      id: json['Id'] as int?,
      userId: json['UserId'] as int?,
      otpNumber: json['OtpNumber'] as int?,
      tokenKey: json['Tokenkey'] as String?,
      createdDate: json['CreatedDate'] as String?,
      isActive: json['IsActive'] as bool?,
      otpCounter: json['OtpCounter'] as int?,
      name: json['Name'] as String?,
      designationName: json['DesignationName'] as String?,
      designationId: json['DesignationId'] as int?,
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'OtpNumber': otpNumber,
      'Tokenkey': tokenKey,
      'CreatedDate': createdDate,
      'IsActive': isActive,
      'OtpCounter': otpCounter,
      'Name': name,
      'DesignationName': designationName,
      'DesignationId': designationId,
    };
  }

  /// Static method to convert a JSON array into a list of model instances.
  static List<VerifyOtpResponse> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => VerifyOtpResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
