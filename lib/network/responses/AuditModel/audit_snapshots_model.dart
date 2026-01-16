
class AuditSnapshotModel {
  final int? auditSnapshotId;
  final int? branchId;
  final String? branchName;
  final String? snapshotName;
  final String? auditStartDate;
  final String? auditEndDate;
  final String? cAuditStartDate;
  final String? cAuditEndDate;
  final bool? isCompleted;
  final String? auditBy;

  AuditSnapshotModel({
    this.auditSnapshotId,
    this.branchId,
    this.branchName,
    this.snapshotName,
    this.auditStartDate,
    this.auditEndDate,
    this.cAuditStartDate,
    this.cAuditEndDate,
    this.isCompleted,
    this.auditBy,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory AuditSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AuditSnapshotModel(
      auditSnapshotId: json['AuditSnapshotId'] as int?,
      branchId: json['BranchId'] as int?,
      branchName: json['BranchName'] as String?,
      snapshotName: json['SnapshotName'] as String?,
      auditStartDate: json['AuditStartDate'] as String?,
      auditEndDate: json['AuditEndDate'] as String?,
      cAuditStartDate: json['cAuditStartDate'] as String?,
      cAuditEndDate: json['cAuditEndDate'] as String?,
      isCompleted: json['IsCompleted'] as bool?,
      auditBy: json['AuditBy'] as String?,
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'AuditSnapshotId': auditSnapshotId,
      'BranchId': branchId,
      'BranchName': branchName,
      'SnapshotName': snapshotName,
      'AuditStartDate': auditStartDate,
      'AuditEndDate': auditEndDate,
      'cAuditStartDate': cAuditStartDate,
      'cAuditEndDate': cAuditEndDate,
      'IsCompleted': isCompleted,
      'AuditBy': auditBy,
    };
  }

  /// Static method to convert a JSON array into a list of model instances.
  static List<AuditSnapshotModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => AuditSnapshotModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
