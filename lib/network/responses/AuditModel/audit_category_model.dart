
class AuditCategoryModel {
  final String? category;
  final int? categoryId;
  final String? module;
  final List<QuestionSubCategory>? questionSubCategories;

  AuditCategoryModel({
    this.category,
    this.categoryId,
    this.module,
    this.questionSubCategories,
  });

  factory AuditCategoryModel.fromJson(Map<String, dynamic> json) {
    return AuditCategoryModel(
      category: json['Category'] as String?,
      categoryId: json['CategoryId'] as int?,
      module: json['Module'] as String?,
      questionSubCategories: (json['QuestionSubCategories'] as List<dynamic>?)
          ?.map((e) => QuestionSubCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Category': category,
      'CategoryId': categoryId,
      'Module': module,
      'QuestionSubCategories':
          questionSubCategories?.map((e) => e.toJson()).toList(),
    };
  }

  /// Convert a list of JSON objects into a list of AuditCategoryModel
  static List<AuditCategoryModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => AuditCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class QuestionSubCategory {
  final int? categoryId;
  final List<Question>? questions;
  final String? subCategory;
  final int? subCategoryId;

  QuestionSubCategory({
    this.categoryId,
    this.questions,
    this.subCategory,
    this.subCategoryId,
  });

  factory QuestionSubCategory.fromJson(Map<String, dynamic> json) {
    return QuestionSubCategory(
      categoryId: json['CategoryId'] as int?,
      questions: (json['Questions'] as List<dynamic>?)
          ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      subCategory: json['SubCategory'] as String?,
      subCategoryId: json['SubCategoryId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CategoryId': categoryId,
      'Questions': questions?.map((e) => e.toJson()).toList(),
      'SubCategory': subCategory,
      'SubCategoryId': subCategoryId,
    };
  }
}

class Question {
  final List<Answer>? answers;
  final String? question;
  final int? questionId;
   int? savedAnswerId;
   String? savedAnswer;
   String? savedComment;
  final QuestionType? questionType;

  Question({
    this.answers,
    this.question,
    this.questionId,
    this.savedAnswerId,
    this.savedAnswer,
    this.savedComment,
    this.questionType,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      answers: (json['Answers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList(),
      question: json['Question'] as String?,
      questionId: json['QuestionId'] as int?,
      savedAnswerId: json['SavedAnswerId'] as int?,
      savedAnswer: json['SavedAnswer'] as String?,
      savedComment: json['SavedComment'] as String?,
      questionType: json['QuestionType'] != null
          ? QuestionType.fromJson(json['QuestionType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Answers': answers?.map((e) => e.toJson()).toList(),
      'Question': question,
      'QuestionId': questionId,
      'SavedAnswerId': savedAnswerId,
      'SavedAnswer': savedAnswer,
      'SavedComment': savedComment,
      'QuestionType': questionType?.toJson(),
    };
  }
}

class Answer {
  final int? id;
  final bool? isUpload;
  final String? option;

  Answer({
    this.id,
    this.isUpload,
    this.option,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['Id'] as int?,
      isUpload: json['IsUpload'] as bool?,
      option: json['Option'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'IsUpload': isUpload,
      'Option': option,
    };
  }
}

class QuestionType {
  final bool? isHighRisk;
  final double? mark;
  final String? typeName;

  QuestionType({
    this.isHighRisk,
    this.mark,
    this.typeName,
  });

  factory QuestionType.fromJson(Map<String, dynamic> json) {
    return QuestionType(
      isHighRisk: json['IsHighRisk'] as bool?,
      mark: json['Mark'] as double?,
      typeName: json['TypeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IsHighRisk': isHighRisk,
      'Mark': mark,
      'TypeName': typeName,
    };
  }
}
