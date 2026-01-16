import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'group_list.dart';

@JsonSerializable()
class CenterModel {
  String? createDate;
  String? centerName;
  int? centerId;
  int? villageId;
  bool? isDisbursed;
  int? groupCount;
  List<GroupModel>? groupList;

  CenterModel({
    this.createDate,
    this.centerName,
    this.centerId,
    this.villageId,
    this.isDisbursed,
    this.groupCount,
    this.groupList,
  });

  factory CenterModel.fromMap(Map<String, dynamic> data) => CenterModel(
        createDate: data['CreateDate'] as String?,
        centerName: data['CenterName'] as String?,
        centerId: data['CenterId'] as int?,
        villageId: data['VillageId'] as int?,
        isDisbursed: data['IsDisbursed'] as bool?,
        groupCount: data['GroupCount'] as int?,
        groupList: GroupModel.listFromJson(data['GroupList']),
      );

  Map<String, dynamic> toMap() => {
        'CreateDate': createDate,
        'CenterName': centerName,
        'CenterId': centerId,
        'VillageId': villageId,
        'IsDisbursed': isDisbursed,
        'GroupCount': groupCount,
        'GroupList': groupList?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [CenterModel].
  factory CenterModel.fromJson(String data) {
    return CenterModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [CenterModel] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [CenterModel]
  static List<CenterModel> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => CenterModel.fromMap(json)).toList();
  }
}
