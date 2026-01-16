import 'dart:convert';

import 'question.dart';

class PostKycModel {
  int? questionCategoryId;
  int? snapshotId;
  int? questionSubCategoryId;
  int? additionalSnapshotId;
  List<SavedQuestion>? questions;

  PostKycModel({
    this.questionCategoryId,
    this.snapshotId,
    this.questionSubCategoryId,
    this.additionalSnapshotId,
    this.questions,
  });

  factory PostKycModel.fromMap(Map<String, dynamic> data) => PostKycModel(
        questionCategoryId: data['QuestionCategoryId'] as int?,
        snapshotId: data['SnapshotId'] as int?,
        questionSubCategoryId: data['QuestionSubCategoryId'] as int?,
        additionalSnapshotId: data['AdditionalSnapshotId'] as int?,
        questions: (data['Questions'] as List<dynamic>?)
            ?.map((e) => SavedQuestion.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'QuestionCategoryId': questionCategoryId,
        'SnapshotId': snapshotId,
        'QuestionSubCategoryId': questionSubCategoryId,
        'AdditionalSnapshotId': additionalSnapshotId,
        'Questions': questions?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PostKycModel].
  factory PostKycModel.fromJson(String data) {
    return PostKycModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PostKycModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
