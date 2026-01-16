import 'package:json_annotation/json_annotation.dart';

part 'voter_card_model.g.dart';

@JsonSerializable()
class VoterCardModel {
  final String? requestId;
  final Result? result;
  final int? statusCode;

  VoterCardModel({this.requestId, this.result, this.statusCode});

  factory VoterCardModel.fromJson(Map<String, dynamic> json) =>
      _$VoterCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoterCardModelToJson(this);
}

@JsonSerializable()
class Result {
  final String? acNo;
  final String? rlnName;
  final String? partNo;
  final String? nameV3;
  final String? psLatLong;
  final String? stCode;
  final String? id;
  final String? pin;
  final String? district;
  final String? rlnNameV1;
  final String? epicNo;
  final String? state;
  final String? slNoInPart;
  final String? sectionNo;
  final String? lastUpdate;
  final String? rlnNameV2;
  final String? rlnNameV3;
  final String? acName;
  final String? psName;
  final String? houseNo;
  final String? rlnType;
  final String? pcName;
  final String? name;
  final String? dob;
  final String? gender;
  final int? age;
  final String? nameV2;
  final String? nameV1;
  final String? partName;

  Result({
    this.acNo,
    this.rlnName,
    this.partNo,
    this.nameV3,
    this.psLatLong,
    this.stCode,
    this.id,
    this.pin,
    this.district,
    this.rlnNameV1,
    this.epicNo,
    this.state,
    this.slNoInPart,
    this.sectionNo,
    this.lastUpdate,
    this.rlnNameV2,
    this.rlnNameV3,
    this.acName,
    this.psName,
    this.houseNo,
    this.rlnType,
    this.pcName,
    this.name,
    this.dob,
    this.gender,
    this.age,
    this.nameV2,
    this.nameV1,
    this.partName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResultToJson(this);
}
