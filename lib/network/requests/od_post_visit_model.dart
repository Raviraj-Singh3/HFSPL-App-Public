
class PostMemberVisitingRequestModel {
  final int? centerId;
  final int? clientId;
  final int? groupId;
  final String? lat;
  final String? lng;
  final int? meetingTypeId;
  final String? observation;
  final int? visitorId;
  final String? nextVisitDate;
  final String? clientReason;

  PostMemberVisitingRequestModel({
    this.centerId,
    this.clientId,
    this.groupId,
    this.lat,
    this.lng,
    this.meetingTypeId,
    this.observation,
    this.visitorId,
    this.nextVisitDate,
    this.clientReason,
  });

  factory PostMemberVisitingRequestModel.fromJson(Map<String, dynamic> json) {
    return PostMemberVisitingRequestModel(
      centerId: json['centerId'],
      clientId: json['clientId'],
      groupId: json['groupId'],
      lat: json['lat'],
      lng: json['lng'],
      meetingTypeId: json['meetingTypeId'],
      observation: json['observation'],
      visitorId: json['visitorId'],
      nextVisitDate: json['NextVisitDate'],
      clientReason: json['ClientReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'clientId': clientId,
      'groupId': groupId,
      'lat': lat,
      'lng': lng,
      'meetingTypeId': meetingTypeId,
      'observation': observation,
      'visitorId': visitorId,
      'NextVisitDate': nextVisitDate,
      'ClientReason': clientReason,
    };
  }
}

// Example Usage:
// Convert JSON to Model
// final model = PostMemberVisitingRequestModel.fromJson(jsonDecode(jsonString));

// Convert Model to JSON
// final jsonString = jsonEncode(model.toJson());
