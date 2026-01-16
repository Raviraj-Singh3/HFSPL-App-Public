import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LoginModel {
  @JsonKey(name: 'Uid')
  final int uid;

  @JsonKey(name: 'Token')
  final String token;

  @JsonKey(name: 'TokenExpireTime')
  final String? tokenExpireTime;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'EmpCode')
  final String empCode;

  @JsonKey(name: 'Designation')
  final String designation;

  @JsonKey(name: 'DesignationId')
  final int designationId;

  @JsonKey(name: 'IsAuditEnable')
  final bool isAuditEnable;

  @JsonKey(name: 'IsGRTEnable')
  final bool isGRTEnable;

  @JsonKey(name: 'CanDoGRT')
  final bool canDoGRT;

  @JsonKey(name: 'Branch')
  final String branch;

  @JsonKey(name: 'EmailId')
  final String emailId;

  @JsonKey(name: 'MobileNumber')
  final int mobileNumber;

  @JsonKey(name: 'ResponseMessage')
  final String responseMessage;

  @JsonKey(name: 'LocationIntervalMS')
  final int locationIntervalMS;

  @JsonKey(name: 'EnableDemandCollection')
  final bool enableDemandCollection;

  LoginModel({
    required this.uid,
    required this.token,
    required this.tokenExpireTime,
    required this.name,
    required this.empCode,
    required this.designation,
    required this.designationId,
    required this.isAuditEnable,
    required this.isGRTEnable,
    required this.canDoGRT,
    required this.branch,
    required this.emailId,
    required this.mobileNumber,
    required this.responseMessage,
    required this.locationIntervalMS,
    required this.enableDemandCollection,
  });

  // Factory method to create an instance from JSON
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      uid: json['Uid'] as int,
      token: json['Token'] as String,
      tokenExpireTime: json['TokenExpireTime'] as String?,
      name: json['Name'] as String,
      empCode: json['EmpCode'] as String,
      designation: json['Designation'] as String,
      designationId: json['DesignationId'] as int,
      isAuditEnable: json['IsAuditEnable'] as bool,
      isGRTEnable: json['IsGRTEnable'] as bool,
      canDoGRT: json['CanDoGRT'] as bool,
      branch: json['Branch'] as String,
      emailId: json['EmailId'] as String,
      mobileNumber: json['MobileNumber'] as int,
      responseMessage: json['ResponseMessage'] as String,
      locationIntervalMS: json['LocationIntervalMS'] as int,
      enableDemandCollection: json['EnableDemandCollection'] as bool,
    );
  }

  // Method to convert an object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Uid': uid,
      'Token': token,
      'TokenExpireTime': tokenExpireTime,
      'Name': name,
      'EmpCode': empCode,
      'Designation': designation,
      'DesignationId': designationId,
      'IsAuditEnable': isAuditEnable,
      'IsGRTEnable': isGRTEnable,
      'CanDoGRT': canDoGRT,
      'Branch': branch,
      'EmailId': emailId,
      'MobileNumber': mobileNumber,
      'ResponseMessage': responseMessage,
      'LocationIntervalMS': locationIntervalMS,
      'EnableDemandCollection': enableDemandCollection,
    };
  }

  // Static method to parse a list of JSON objects
  static List<LoginModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => LoginModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
