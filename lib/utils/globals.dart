import 'dart:typed_data';

import '../network/responses/kyc/kyc_status.dart';

String Global_uid = '';
String Global_token = '';
//String Global_mobile = '';
String Global_name = '';
String Global_designationName = '';
String Global_LoginId = '';
String Global_Password = '';
bool IsAuditEnable = false;
bool IsFE = false;
bool IsGRTEnable = false;
bool EnableDemandCollection = false;
bool CanDoGRT = false;
Uint8List? Global_profileImageBytes;

List<KycStatus> Global_kycStatusList = [];
