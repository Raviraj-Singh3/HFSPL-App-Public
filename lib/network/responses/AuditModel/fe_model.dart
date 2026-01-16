class ActiveFeModel {
  final int? feId;
  final String? feName;

  ActiveFeModel({
    this.feId,
    this.feName,
  });

  factory ActiveFeModel.fromJson(Map<String, dynamic> json) {
    return ActiveFeModel(
      feId: json['FEID'] as int?,
      feName: json['FENAME'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FEID': feId,
      'FENAME': feName,
    };
  }

  /// Convert a list of JSON objects into a list of ActiveFeModel
  static List<ActiveFeModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => ActiveFeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
