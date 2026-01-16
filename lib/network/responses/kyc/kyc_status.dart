import 'dart:convert';

class KycStatus {
  int? id;
  int? snapshotId;
  int? catId;
  int? subcatId;
  int? additionalMemberId;
  bool? isCompleted;

  KycStatus({
    this.id,
    this.snapshotId,
    this.catId,
    this.subcatId,
    this.additionalMemberId,
    this.isCompleted,
  });

  factory KycStatus.fromMap(Map<String, dynamic> data) => KycStatus(
        id: data['Id'] as int?,
        snapshotId: data['SnapshotId'] as int?,
        catId: data['CatId'] as int?,
        subcatId: data['SubcatId'] as int?,
        additionalMemberId: data['AdditionalMemberId'] as int?,
        isCompleted: data['IsCompleted'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'Id': id,
        'SnapshotId': snapshotId,
        'CatId': catId,
        'SubcatId': subcatId,
        'AdditionalMemberId': additionalMemberId,
        'IsCompleted': isCompleted,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [KycStatus].
  factory KycStatus.fromJson(String data) {
    return KycStatus.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [KycStatus] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [KycStatus]
  static List<KycStatus> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => KycStatus.fromMap(json)).toList();
  }
}
