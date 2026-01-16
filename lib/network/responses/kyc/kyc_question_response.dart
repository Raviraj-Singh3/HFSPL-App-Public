import 'dart:convert';

class KycQuestion {
  int? questionId;
  int? snapshotId;
  int? catId;
  int? subCatId;
  String? questionType;
  String? questionName;
  int? order;
  bool? required;
  List<dynamic>? options;
  String? savedAnswer;

  KycQuestion({
    this.questionId,
    this.snapshotId,
    this.catId,
    this.subCatId,
    this.questionType,
    this.questionName,
    this.order,
    this.required,
    this.options,
    this.savedAnswer,
  });

  factory KycQuestion.fromMap(Map<String, dynamic> data) {
    return KycQuestion(
      questionId: data['QuestionId'] as int?,
      snapshotId: data['SnapshotId'] as int?,
      catId: data['CatId'] as int?,
      subCatId: data['SubCatId'] as int?,
      questionType: data['QuestionType'] as String?,
      questionName: data['QuestionName'] as String?,
      order: data['Order'] as int?,
      required: data['Required'] as bool?,
      options: data['Options'] as List<dynamic>?,
      savedAnswer: data['SavedAnswer'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'QuestionId': questionId,
        'SnapshotId': snapshotId,
        'CatId': catId,
        'SubCatId': subCatId,
        'QuestionType': questionType,
        'QuestionName': questionName,
        'Order': order,
        'Required': required,
        'Options': options,
        'SavedAnswer': savedAnswer,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [KycQuestion].
  factory KycQuestion.fromJson(String data) {
    return KycQuestion.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [KycQuestion] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [KycQuestion]
  static List<KycQuestion> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => KycQuestion.fromMap(json)).toList();
  }
}
