
class ActiveGroupsModel {
  final int? groupId;
  final String? groupName;

  ActiveGroupsModel({
    this.groupId,
    this.groupName,
  });

  factory ActiveGroupsModel.fromJson(Map<String, dynamic> json) {
    return ActiveGroupsModel(
      groupId: json['GROUPID'] as int?,
      groupName: json['GROUPNAME'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GROUPID': groupId,
      'GROUPNAME': groupName,
    };
  }

  /// Convert a list of JSON objects into a list of ActiveGroupsModel
  static List<ActiveGroupsModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) =>
            ActiveGroupsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
