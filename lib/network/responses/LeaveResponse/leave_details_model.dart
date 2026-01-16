class LeaveDetailsModel {
  final List<LeaveDetail>? data;
  final List<dynamic>? images;

  LeaveDetailsModel({this.data, this.images});

  factory LeaveDetailsModel.fromJson(Map<String, dynamic> json) {
    return LeaveDetailsModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LeaveDetail.fromJson(e))
          .toList(),
      images: json['images'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data?.map((e) => e.toJson()).toList(),
      "images": images,
    };
  }
}

class LeaveDetail {
  final int? id;
  final String? lGuid;
  final String? toReport;
  final int? toReportId;
  final String? createdBy;
  final String? leaveDate;
  final String? leaveCreateTime;
  final bool? isActive;
  final int? totalLeaveDays;
  final String? description;
  final bool? isApproved;
  final String? name;
  final String? leaveName;
  final String? lTypeName;

  LeaveDetail({
    this.id,
    this.lGuid,
    this.toReport,
    this.toReportId,
    this.createdBy,
    this.leaveDate,
    this.leaveCreateTime,
    this.isActive,
    this.totalLeaveDays,
    this.description,
    this.isApproved,
    this.name,
    this.leaveName,
    this.lTypeName,
  });

  factory LeaveDetail.fromJson(Map<String, dynamic> json) {
    return LeaveDetail(
      id: json['id'] as int?,
      lGuid: json['LGUID'] as String?,
      toReport: json['ToReport'] as String?,
      toReportId: json['ToReportId'] as int?,
      createdBy: json['CreatedBy'] as String?,
      leaveDate: json['Leave_Date'] as String?,
      leaveCreateTime: json['Leave_CreateTime'] as String?,
      isActive: json['IsActive'] as bool?,
      totalLeaveDays: json['Total_Leave_Days'] as int?,
      description: json['Description'] as String?,
      isApproved: json['IsApproved'] as bool?,
      name: json['Name'] as String?,
      leaveName: json['LEAVE_NAME'] as String?,
      lTypeName: json['lTypeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "LGUID": lGuid,
      "ToReport": toReport,
      "ToReportId": toReportId,
      "CreatedBy": createdBy,
      "Leave_Date": leaveDate,
      "Leave_CreateTime": leaveCreateTime,
      "IsActive": isActive,
      "Total_Leave_Days": totalLeaveDays,
      "Description": description,
      "IsApproved": isApproved,
      "Name": name,
      "LEAVE_NAME": leaveName,
      "lTypeName": lTypeName,
    };
  }
}
