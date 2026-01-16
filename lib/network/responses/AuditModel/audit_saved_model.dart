
class SavedAuditResponseModel {
   int? answerId;
  final int? auditSnapshotItemId;
  final int? auditSnapshotModuleId;
   String? comment;
  final String? answer;
  final String? customValue;
  final int? questionId;

  SavedAuditResponseModel({
    this.answerId,
    this.auditSnapshotItemId,
    this.auditSnapshotModuleId,
    this.comment,
    this.answer,
    this.customValue,
    this.questionId,
  });

  factory SavedAuditResponseModel.fromJson(Map<String, dynamic> json) {
    return SavedAuditResponseModel(
      answerId: json['AnswerId'] as int?,
      auditSnapshotItemId: json['AuditSnapshotItemId'] as int?,
      auditSnapshotModuleId: json['AuditSnapshotModuleId'] as int?,
      comment: json['Comment'] as String?,
      answer: json['Answer'] as String?,
      customValue: json['CustomValue'] as String?,
      questionId: json['QuestionId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AnswerId': answerId,
      'AuditSnapshotItemId': auditSnapshotItemId,
      'AuditSnapshotModuleId': auditSnapshotModuleId,
      'Comment': comment,
      'Answer': answer,
      'CustomValue': customValue,
      'QuestionId': questionId,
    };
  }

  /// Convert a list of JSON objects into a list of SavedAuditResponseModel
  static List<SavedAuditResponseModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) =>
            SavedAuditResponseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
