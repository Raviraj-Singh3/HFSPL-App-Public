import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class KycCategory {
  String? name;
  int? id;
  int? snapshotId;

  KycCategory({this.name, this.id, this.snapshotId});

  factory KycCategory.fromMap(Map<String, dynamic> data) {
    return KycCategory(
      name: data['Name'] as String?,
      id: data['Id'] as int?,
      snapshotId: data['SnapshotId'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'Name': name,
        'Id': id,
        'SnapshotId': snapshotId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [KycCategory].
  factory KycCategory.fromJson(String data) {
    return KycCategory.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [KycCategory] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [KycCategory]
  static List<KycCategory> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => KycCategory.fromMap(json)).toList();
  }
}
