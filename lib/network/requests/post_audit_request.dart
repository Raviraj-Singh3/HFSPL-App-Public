class RequestPostAudit {
   int? branchId;
   int? centerId;
   int? clientId;
   String? comment;
   String? customValue;
   int? feid;
   int? groupId;
   int? questionSubCategoryId;
   List<QuestionRequest>? questions;
   int? snapshotId;

  RequestPostAudit({
    this.branchId,
    this.centerId,
    this.clientId,
    this.comment,
    this.customValue,
    this.feid,
    this.groupId,
    this.questionSubCategoryId,
    this.questions,
    this.snapshotId,
  });

  factory RequestPostAudit.fromJson(Map<String, dynamic> json) {
    return RequestPostAudit(
      branchId: json['BranchId'] as int?,
      centerId: json['CenterId'] as int?,
      clientId: json['ClientId'] as int?,
      comment: json['Comment'] as String?,
      customValue: json['CustomValue'] as String?,
      feid: json['Feid'] as int?,
      groupId: json['GroupId'] as int?,
      questionSubCategoryId: json['QuestionSubCategoryId'] as int?,
      questions: (json['Questions'] as List<dynamic>?)
          ?.map((e) => QuestionRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      snapshotId: json['SnapshotId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BranchId': branchId,
      'CenterId': centerId,
      'ClientId': clientId,
      'Comment': comment,
      'CustomValue': customValue,
      'Feid': feid,
      'GroupId': groupId,
      'QuestionSubCategoryId': questionSubCategoryId,
      'Questions': questions?.map((e) => e.toJson()).toList(),
      'SnapshotId': snapshotId,
    };
  }

  /// Convert a list of JSON objects into a list of RequestPostAudit
  static List<RequestPostAudit> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => RequestPostAudit.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class QuestionRequest {
   int? auditSnapshotItemId;
   String? comment;
   String? customValue;
   int? questionId;
   int? selectedAnswerId;
   bool? imageValidation;

  QuestionRequest({
    this.auditSnapshotItemId,
    this.comment,
    this.customValue,
    this.questionId,
    this.selectedAnswerId,
    this.imageValidation,
  });

  factory QuestionRequest.fromJson(Map<String, dynamic> json) {
    return QuestionRequest(
      auditSnapshotItemId: json['AuditSnapshotItemId'] as int?,
      comment: json['Comment'] as String?,
      customValue: json['CustomValue'] as String?,
      questionId: json['QuestionId'] as int?,
      selectedAnswerId: json['SelectedAnswerId'] as int?,
      imageValidation: json['ImageValidation'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AuditSnapshotItemId': auditSnapshotItemId,
      'Comment': comment,
      'CustomValue': customValue,
      'QuestionId': questionId,
      'SelectedAnswerId': selectedAnswerId,
      'ImageValidation': imageValidation,
    };
  }

  /// Convert a list of JSON objects into a list of Question
  static List<QuestionRequest> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => QuestionRequest.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
