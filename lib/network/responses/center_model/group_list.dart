import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class GroupModel {
  String? groupName;
  String? createDate;
  int? groupId;
  int? centerId;
  bool? isDisbursed;

  GroupModel({
    this.groupName,
    this.createDate,
    this.groupId,
    this.centerId,
    this.isDisbursed,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data) => GroupModel(
        groupName: data['GroupName'] as String?,
        createDate: data['CreateDate'] as String?,
        groupId: data['GroupId'] as int?,
        centerId: data['CenterId'] as int?,
        isDisbursed: data['IsDisbursed'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'GroupName': groupName,
        'CreateDate': createDate,
        'GroupId': groupId,
        'CenterId': centerId,
        'IsDisbursed': isDisbursed,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [GroupModel].
  factory GroupModel.fromJson(String data) {
    return GroupModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [GroupModel] to a JSON string.
  String toJson() => json.encode(toMap());

  static List<GroupModel> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => GroupModel.fromMap(json)).toList();
  }
}
