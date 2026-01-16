class CenterMonitorResponse {
  final int id;
  final String name;

  CenterMonitorResponse({
    required this.id,
    required this.name,
  });

  factory CenterMonitorResponse.fromJson(Map<String, dynamic> json) {
    return CenterMonitorResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  static List<CenterMonitorResponse> listFromJson(dynamic jsonList) {
    return (jsonList as List)
        .map((json) => CenterMonitorResponse.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
