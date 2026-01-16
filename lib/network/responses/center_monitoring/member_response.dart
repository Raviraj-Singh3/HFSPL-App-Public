class MemberResponse {
  final int id;
  final String name;
  final String relativeName;
  final bool selected;
  final String observation;

  MemberResponse({
    required this.id,
    required this.name,
    required this.relativeName,
    this.selected = true,
    this.observation = '',
  });

  factory MemberResponse.fromJson(Map<String, dynamic> json) {
    return MemberResponse(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
      relativeName: json['RelativeName'] ?? '',
      selected: json['selected'] ?? true,
      observation: json['observation'] ?? '',
    );
  }

  static List<MemberResponse> listFromJson(dynamic jsonList) {
    return (jsonList as List)
        .map((json) => MemberResponse.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'RelativeName': relativeName,
      'selected': selected,
      'observation': observation,
    };
  }

  MemberResponse copyWith({
    int? id,
    String? name,
    String? relativeName,
    bool? selected,
    String? observation,
  }) {
    return MemberResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      relativeName: relativeName ?? this.relativeName,
      selected: selected ?? this.selected,
      observation: observation ?? this.observation,
    );
  }
}
