
import 'package:flutter/material.dart';

class SnapshotModel {
  int? id;
  String? name;
  int? groupId;
  int? loanType;
  int? status;
  String? cDate;
  dynamic nomineeSnapshotId;

  SnapshotModel({
    this.id,
    this.name,
    this.groupId,
    this.loanType,
    this.status,
    this.cDate,
    this.nomineeSnapshotId,
  });

  String getStatus() {
    if (status == 0) {
      return "Draft";
    } else if (status == 1) {
      return "Submitted";
    }
    else if (status == 2) {
      return "Checked";
    }
    
    return "";
  }

  Color getStatusColor() {
    if (status == 0) {
      return Colors.red.shade700;
    } else if (status == 1) {
      return Colors.yellow.shade700;
    }
    else if (status == 2) {
      return Colors.green.shade700;
    }
    return Colors.black;
  }

  factory SnapshotModel.fromJson(Map<String, dynamic> json) => SnapshotModel(
        id: json['Id'] as int?,
        name: json['Name'] as String?,
        groupId: json['GroupId'] as int?,
        loanType: json['LoanType'] as int?,
        status: json['Status'] as int?,
        cDate: json['cDate'] as String?,
        nomineeSnapshotId: json['NomineeSnapshotId'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Name': name,
        'GroupId': groupId,
        'LoanType': loanType,
        'Status': status,
        'cDate': cDate,
        'NomineeSnapshotId': nomineeSnapshotId,
      };

  /// Added factory method to parse a list of [SnapshotModel]
  static List<SnapshotModel> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => SnapshotModel.fromJson(json)).toList();
  }
}
