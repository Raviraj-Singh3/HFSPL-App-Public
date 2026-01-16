
class AuditMembersModel {
  final int? clientId;
  final String? clientName;
  final String? relativeName;

  AuditMembersModel({
    this.clientId,
    this.clientName,
    this.relativeName,
  });

  factory AuditMembersModel.fromJson(Map<String, dynamic> json) {
    return AuditMembersModel(
      clientId: json['CLIENTID'] as int?,
      clientName: json['CLIENTNAME'] as String?,
      relativeName: json['RelativeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CLIENTID': clientId,
      'CLIENTNAME': clientName,
      'RelativeName': relativeName,
    };
  }

  /// Convert a list of JSON objects into a list of AuditMembersModel
  static List<AuditMembersModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => AuditMembersModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
