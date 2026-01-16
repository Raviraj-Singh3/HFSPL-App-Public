class OverdueCallingRemarkResponse {
  final int? clientId;
  final String? finalRemark;
  final String? finalRemarkStatus;
  final List<RemarkDetail>? remarkDetails;

  OverdueCallingRemarkResponse({
    this.clientId,
    this.finalRemark,
    this.finalRemarkStatus,
    this.remarkDetails,
  });

  factory OverdueCallingRemarkResponse.fromJson(Map<String, dynamic> json) {
    return OverdueCallingRemarkResponse(
      clientId: json['ClientId'],
      finalRemark: json['FinalRemark'],
      finalRemarkStatus: json['FinalRemarkStatus'],
      remarkDetails: json['RemarkDetails'] != null
          ? (json['RemarkDetails'] as List)
              .map((x) => RemarkDetail.fromJson(x))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ClientId': clientId,
      'FinalRemark': finalRemark,
      'FinalRemarkStatus': finalRemarkStatus,
      'RemarkDetails': remarkDetails?.map((x) => x.toJson()).toList(),
    };
  }
}

class RemarkDetail {
  final String? remark;
  final String? notes;
  final String? dateTime;
  final String? staffName;
  final int? callerId;

  RemarkDetail({
    this.remark,
    this.notes,
    this.dateTime,
    this.staffName,
    this.callerId,
  });

  factory RemarkDetail.fromJson(Map<String, dynamic> json) {
    return RemarkDetail(
      remark: json['Remark'],
      notes: json['Notes'],
      dateTime: json['DateTime'],
      staffName: json['StaffName'],
      callerId: json['CallerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Remark': remark,
      'Notes': notes,
      'DateTime': dateTime,
      'StaffName': staffName,
      'CallerId': callerId,
    };
  }
}
