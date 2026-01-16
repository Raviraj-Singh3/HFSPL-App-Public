import 'dart:convert';

class KycSubCategory {
  String? name;
  int? id;

  KycSubCategory({this.name, this.id});

  factory KycSubCategory.fromMap(Map<String, dynamic> data) {
    return KycSubCategory(
        name: data['Name'] as String?, id: data['Id'] as int?);
  }

  Map<String, dynamic> toMap() => {'Name': name, 'Id': id};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [KycCategoryResponse].
  factory KycSubCategory.fromJson(String data) {
    return KycSubCategory.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [KycCategoryResponse] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Added factory method to parse a list of [KycCategoryResponse]
  static List<KycSubCategory> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => KycSubCategory.fromMap(json)).toList();
  }
}
