
class GetGrievanceCategoriesResponse {
  final int? id;
  final String? title;
  final List<SubCategory>? subCategories;

  GetGrievanceCategoriesResponse({
    this.id,
    this.title,
    this.subCategories,
  });

  factory GetGrievanceCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return GetGrievanceCategoriesResponse(
      id: json['Id'],
      title: json['Title'],
      subCategories: (json['SubCategories'] as List<dynamic>?)
          ?.map((e) => SubCategory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'SubCategories': subCategories?.map((e) => e.toJson()).toList(),
    };
  }

  static List<GetGrievanceCategoriesResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => GetGrievanceCategoriesResponse.fromJson(json))
        .toList();
  }
}

class SubCategory {
  final int? id;
  final String? title;

  SubCategory({
    this.id,
    this.title,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['Id'],
      title: json['Title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
    };
  }

  static List<SubCategory> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => SubCategory.fromJson(json)).toList();
  }
}
