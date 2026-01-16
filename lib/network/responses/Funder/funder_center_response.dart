class FunderCenterResponse {
  final int centerId;
  final String centerName;

  FunderCenterResponse({
    required this.centerId,
    required this.centerName,
  });

  factory FunderCenterResponse.fromJson(Map<String, dynamic> json) {
    return FunderCenterResponse(
      centerId: json['CENTERID'] as int,
      centerName: json['CENTERNAME'] as String,
    );
  }

  static List<FunderCenterResponse> listFromJson(List<dynamic> json) {
    return json.map((e) => FunderCenterResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'CENTERID': centerId,
      'CENTERNAME': centerName,
    };
  }
} 