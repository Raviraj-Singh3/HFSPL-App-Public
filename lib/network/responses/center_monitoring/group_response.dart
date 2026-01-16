class GroupResponse {
  final int id;
  final String name;
  final bool selected;

  GroupResponse({
    required this.id,
    required this.name,
    this.selected = false,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      selected: json['selected'] ?? false,
    );
  }

  static List<GroupResponse> listFromJson(dynamic jsonList) {
    return (jsonList as List)
        .map((json) => GroupResponse.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'selected': selected,
    };
  }

  GroupResponse copyWith({
    int? id,
    String? name,
    bool? selected,
  }) {
    return GroupResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      selected: selected ?? this.selected,
    );
  }
}
