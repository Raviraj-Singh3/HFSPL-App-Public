class VerifyOwnFundNonVerifiedMembers {
  final int id;
  final String name;
  final String? relativeName;
  final String? memberPhone1;
  final String? memberPhone2;

  VerifyOwnFundNonVerifiedMembers({
    required this.id,
    required this.name,
    this.relativeName,
    this.memberPhone1,
    this.memberPhone2,
  });

  factory VerifyOwnFundNonVerifiedMembers.fromJson(Map<String, dynamic> json) {
    return VerifyOwnFundNonVerifiedMembers(
      id: json['Id'] as int,
      name: json['Name'] as String,
      relativeName: json['RelativeName'] as String?,
      memberPhone1: _parsePhoneNumber(json['MemberPhone1']),
      memberPhone2: _parsePhoneNumber(json['MemberPhone2']),
    );
  }

  static String? _parsePhoneNumber(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.isEmpty ? null : value;
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }

  static List<VerifyOwnFundNonVerifiedMembers> listFromJson(List<dynamic> json) {
    return json.map((e) => VerifyOwnFundNonVerifiedMembers.fromJson(e)).toList();
  }
}
