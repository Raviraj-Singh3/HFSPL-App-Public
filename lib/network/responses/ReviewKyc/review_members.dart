class ReviewMembersModel {
  final int? clientId;
  final String? clientName;
  final String? relativeName;
  final String? hmDtm;
  final int? clientCgtId;
  final String? createDtm;

  ReviewMembersModel({
    this.clientId,
    this.clientName,
    this.relativeName,
    this.hmDtm,
    this.clientCgtId,
    this.createDtm,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory ReviewMembersModel.fromJson(Map<String, dynamic> json) {
    return ReviewMembersModel(
      clientId: json['ClientId'] as int?,
      clientName: json['ClientName'] as String?,
      relativeName: json['RelativeName'] as String?,
      hmDtm: json['HmDtm'] as String?,
      clientCgtId: json['ClientCgtId'] as int?,
      createDtm: json['CreateDtm'] as String?,
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'ClientId': clientId,
      'ClientName': clientName,
      'RelativeName': relativeName,
      'HmDtm': hmDtm,
      'ClientCgtId': clientCgtId,
      'CreateDtm': createDtm,
    };
  }

  /// Static method to convert a JSON array into a list of model instances.
  static List<ReviewMembersModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) =>
            ReviewMembersModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
