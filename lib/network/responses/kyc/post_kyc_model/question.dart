import 'dart:convert';

class SavedQuestion {
  int? questionId;
  String? answer;
  int? savedAnswerId;

  SavedQuestion({this.questionId, this.answer, this.savedAnswerId});

  factory SavedQuestion.fromMap(Map<String, dynamic> data) => SavedQuestion(
        questionId: data['QuestionId'] as int?,
        answer: data['Answer'] as String?,
        savedAnswerId: data['SavedAnswerId'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'QuestionId': questionId,
        'Answer': answer,
        'SavedAnswerId': savedAnswerId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [SavedQuestion].
  factory SavedQuestion.fromJson(String data) {
    return SavedQuestion.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SavedQuestion] to a JSON string.
  String toJson() => json.encode(toMap());
}
