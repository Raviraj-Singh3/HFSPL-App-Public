import 'package:flutter/foundation.dart';

class LeaveRequestModel {
  final int? createdBy;
  final String? description;
  final bool? isApproved;
  final int? lID;
  final int? lTypeDay;
  final String? leaveDate;
  final int? staffif;
  final int? toReport;

  LeaveRequestModel({
    this.createdBy,
     this.description,
     this.isApproved,
     this.lID,
     this.lTypeDay,
    this.leaveDate,
     this.staffif,
     this.toReport,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      createdBy: json['CreatedBy'] ?? 0,
      description: json['Description'] ?? '',
      isApproved: json['IsApproved'] ?? false,
      lID: json['LID'] ?? 0,
      lTypeDay: json['LTypeDay'] ?? 0,
      leaveDate: json['Leave_Date'] ?? '',
      staffif: json['Staffif'] ?? 0,
      toReport: json['ToReport'] ?? 0,
    );
  }

  static List<LeaveRequestModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => LeaveRequestModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "CreatedBy": createdBy,
      "Description": description,
      "IsApproved": isApproved,
      "LID": lID,
      "LTypeDay": lTypeDay,
      "Leave_Date": leaveDate,
      "Staffif": staffif,
      "ToReport": toReport,
    };
  }
}
