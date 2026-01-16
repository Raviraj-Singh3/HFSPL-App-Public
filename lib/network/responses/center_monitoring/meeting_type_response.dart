class MeetingTypeResponse {
  final int id;
  final String typeOfMeet;

  MeetingTypeResponse({
    required this.id,
    required this.typeOfMeet,
  });

  factory MeetingTypeResponse.fromJson(Map<String, dynamic> json) {
    return MeetingTypeResponse(
      id: json['ID'] ?? 0,
      typeOfMeet: json['TYPEOFMEET'] ?? '',
    );
  }

  static List<MeetingTypeResponse> listFromJson(dynamic jsonList) {
    return (jsonList as List)
        .map((json) => MeetingTypeResponse.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TYPEOFMEET': typeOfMeet,
    };
  }
}
