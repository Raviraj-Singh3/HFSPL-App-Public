import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class KycAdditionalMember {
  String? name;
  int? id;
  int? snapshotId;
  bool? isNominee;

  KycAdditionalMember({this.name, this.id, this.snapshotId, this.isNominee});

  factory KycAdditionalMember.fromMap(Map<String, dynamic> data) {
    return KycAdditionalMember(
      name: data['Name'] as String?,
      id: data['Id'] as int?,
      snapshotId: data['SnapshotId'] as int?,
      isNominee: data['IsNominee'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
        'Name': name,
        'Id': id,
        'SnapshotId': snapshotId,
        'IsNominee': isNominee,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [KycAdditionalMember].
  factory KycAdditionalMember.fromJson(String data) {
    return KycAdditionalMember.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [KycAdditionalMember] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [KycAdditionalMember]
  static List<KycAdditionalMember> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => KycAdditionalMember.fromMap(json)).toList();
  }
}
