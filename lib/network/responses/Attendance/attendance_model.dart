class AttendanceModel {
  String? dateTime; // Changed to String
  String? pTime;
  String? oTime;
  bool? aStatus;
   AttendanceRequest? attReq;

  AttendanceModel({
    this.dateTime,
    this.pTime,
    this.oTime,
    this.aStatus,
    this.attReq,
  });

  // Factory method to create an AttendanceModel object from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      dateTime: json['dateTime'] as String?, // No DateTime parsing, directly as String
      pTime: json['PTime'] as String?,
      oTime: json['OTime'] as String?,
      aStatus: json['AStatus'] as bool?,
      attReq: json['AttReq'] != null
          ? AttendanceRequest.fromJson(json['AttReq'])
          : null,
    );
  }

  // Method to convert an AttendanceModel object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime, // Directly as String
      'PTime': pTime,
      'OTime': oTime,
      'AStatus': aStatus,
      'AttReq': attReq?.toJson(),
    };
  }

  // Method to convert a list of JSON objects into a list of AttendanceModel objects
  static List<AttendanceModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
class AttendanceRequest {
  final String? status;
  final String? comment;

  AttendanceRequest({
    this.status,
    this.comment,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      status: json['Status'] as String?,
      comment: json['Comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Comment': comment,
    };
  }
}