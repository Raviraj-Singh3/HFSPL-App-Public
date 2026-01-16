class VerifyOwnFundNonVerifiedGroups {
  final int id;
  final String name;

  VerifyOwnFundNonVerifiedGroups({
    required this.id,
    required this.name,
  });

  factory VerifyOwnFundNonVerifiedGroups.fromJson(Map<String, dynamic> json) {
    return VerifyOwnFundNonVerifiedGroups(
      id: json['Id'] as int,
      name: json['Name'] as String,
    );
  }

  static List<VerifyOwnFundNonVerifiedGroups> listFromJson(List<dynamic> json) {
    return json.map((e) => VerifyOwnFundNonVerifiedGroups.fromJson(e)).toList();
  }
} 