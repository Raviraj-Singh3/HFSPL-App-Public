// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voter_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoterCardModel _$VoterCardModelFromJson(Map<String, dynamic> json) =>
    VoterCardModel(
      requestId: json['requestId'] as String?,
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VoterCardModelToJson(VoterCardModel instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'result': instance.result,
      'statusCode': instance.statusCode,
    };

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      acNo: json['acNo'] as String?,
      rlnName: json['rlnName'] as String?,
      partNo: json['partNo'] as String?,
      nameV3: json['nameV3'] as String?,
      psLatLong: json['psLatLong'] as String?,
      stCode: json['stCode'] as String?,
      id: json['id'] as String?,
      pin: json['pin'] as String?,
      district: json['district'] as String?,
      rlnNameV1: json['rlnNameV1'] as String?,
      epicNo: json['epicNo'] as String?,
      state: json['state'] as String?,
      slNoInPart: json['slNoInPart'] as String?,
      sectionNo: json['sectionNo'] as String?,
      lastUpdate: json['lastUpdate'] as String?,
      rlnNameV2: json['rlnNameV2'] as String?,
      rlnNameV3: json['rlnNameV3'] as String?,
      acName: json['acName'] as String?,
      psName: json['psName'] as String?,
      houseNo: json['houseNo'] as String?,
      rlnType: json['rlnType'] as String?,
      pcName: json['pcName'] as String?,
      name: json['name'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      age: (json['age'] as num?)?.toInt(),
      nameV2: json['nameV2'] as String?,
      nameV1: json['nameV1'] as String?,
      partName: json['partName'] as String?,
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'acNo': instance.acNo,
      'rlnName': instance.rlnName,
      'partNo': instance.partNo,
      'nameV3': instance.nameV3,
      'psLatLong': instance.psLatLong,
      'stCode': instance.stCode,
      'id': instance.id,
      'pin': instance.pin,
      'district': instance.district,
      'rlnNameV1': instance.rlnNameV1,
      'epicNo': instance.epicNo,
      'state': instance.state,
      'slNoInPart': instance.slNoInPart,
      'sectionNo': instance.sectionNo,
      'lastUpdate': instance.lastUpdate,
      'rlnNameV2': instance.rlnNameV2,
      'rlnNameV3': instance.rlnNameV3,
      'acName': instance.acName,
      'psName': instance.psName,
      'houseNo': instance.houseNo,
      'rlnType': instance.rlnType,
      'pcName': instance.pcName,
      'name': instance.name,
      'dob': instance.dob,
      'gender': instance.gender,
      'age': instance.age,
      'nameV2': instance.nameV2,
      'nameV1': instance.nameV1,
      'partName': instance.partName,
    };
