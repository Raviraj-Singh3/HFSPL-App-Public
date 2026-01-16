class ReviewGroupModel {
  final String branchName;
  final int branchId;
  final int centerId;
  final String centerName;
  final int groupId;
  final String groupName;

  ReviewGroupModel({
    required this.branchName,
    required this.branchId,
    required this.centerId,
    required this.centerName,
    required this.groupId,
    required this.groupName,
  });

  factory ReviewGroupModel.fromJson(Map<String, dynamic> json) {
    return ReviewGroupModel(
      branchName: json['BranchName'] as String,
      branchId: json['BranchId'] as int,
      centerId: json['CenterId'] as int,
      centerName: json['CenterName'] as String,
      groupId: json['GroupId'] as int,
      groupName: json['GroupName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BranchName': branchName,
      'BranchId': branchId,
      'CenterId': centerId,
      'CenterName': centerName,
      'GroupId': groupId,
      'GroupName': groupName,
    };
  }

  /// Converts a List<dynamic> into a List<ReviewGroupModel>.
  static List<ReviewGroupModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => ReviewGroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
