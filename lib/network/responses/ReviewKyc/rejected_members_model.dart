class RejectedMembersModel {
  final int? clientId;
  final String? clientName;
  final int? clientCgtId;
  final String? relativeName;
  final List<RejectReason>? rejectReasons;

  RejectedMembersModel({
    this.clientId,
    this.clientName,
    this.clientCgtId,
    this.relativeName,
    this.rejectReasons,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory RejectedMembersModel.fromJson(Map<String, dynamic> json) {
    return RejectedMembersModel(
      clientId: json['ClientId'] as int?,
      clientName: json['ClientName'] as String?,
      clientCgtId: json['ClientCgtId'] as int?,
      relativeName: json['RelativeName'] as String?,
      rejectReasons: (json['RejectReasons'] as List<dynamic>?)
          ?.map((e) => RejectReason.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'ClientId': clientId,
      'ClientName': clientName,
      'ClientCgtId': clientCgtId,
      'RelativeName': relativeName,
      'RejectReasons': rejectReasons?.map((e) => e.toJson()).toList(),
    };
  }

  /// Static method to convert a JSON array into a list of model instances.
  static List<RejectedMembersModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) =>
            RejectedMembersModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class RejectReason {
  final int? rejectStatus;
  final String? rejectReasonString;
  final String? rejectedBy;
  final String? rejectedDtm;

  RejectReason({
    this.rejectStatus,
    this.rejectReasonString,
    this.rejectedBy,
    this.rejectedDtm,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory RejectReason.fromJson(Map<String, dynamic> json) {
    return RejectReason(
      rejectStatus: json['RejectStatus'] as int?,
      rejectReasonString: json['RejectReasonString'] as String?,
      rejectedBy: json['RejectedBy'] as String?,
      rejectedDtm: json['RejectedDtm'] as String?,
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'RejectStatus': rejectStatus,
      'RejectReasonString': rejectReasonString,
      'RejectedBy': rejectedBy,
      'RejectedDtm': rejectedDtm,
    };
  }
}
