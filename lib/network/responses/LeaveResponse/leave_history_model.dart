class LeaveHistoryModel {
  final bool cancelable;
  final String guid;
  final String cDate;
  final String formattedDate;
  final String responseDate;
  final List<LeaveModel> leaves;

  LeaveHistoryModel({
    required this.cancelable,
    required this.guid,
    required this.cDate,
    required this.formattedDate,
    required this.responseDate,
    required this.leaves,
  });

  factory LeaveHistoryModel.fromJson(Map<String, dynamic> json) {
    return LeaveHistoryModel(
      cancelable: json['Cancelable'] ?? false,
      guid: json['guid'] ?? '',
      cDate: json['cDate'] ?? '',
      formattedDate: json['formatedDate'] ?? '',
      responseDate: json['responseDate'] ?? '',
      leaves: (json['leaves'] as List<dynamic>?)
          ?.map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  static List<LeaveHistoryModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => LeaveHistoryModel.fromJson(e)).toList();
  }
}

class LeaveModel {
  final int leaveId;
  final String leaveName;
  final String leaveShortName;
  final String leaveDayTypeName;
  final String status;
  final String comment;
  final String leaveDate;

  LeaveModel({
    required this.leaveId,
    required this.leaveName,
    required this.leaveShortName,
    required this.leaveDayTypeName,
    required this.status,
    required this.comment,
    required this.leaveDate,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveId: json['LeaveId'] ?? 0,
      leaveName: json['LeaveName'] ?? '',
      leaveShortName: json['LeaveShortName'] ?? '',
      leaveDayTypeName: json['LeaveDayTypeName'] ?? '',
      status: json['Status'] ?? '',
      comment: json['Comment'] ?? '',
      leaveDate: json['LeaveDate'] ?? '',
    );
  }
}
