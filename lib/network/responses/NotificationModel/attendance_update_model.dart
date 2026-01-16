class AttendanceUpdateModel {
  final AttendanceRequest? request;
  final Staff? staff;

  AttendanceUpdateModel({
    this.request,
    this.staff,
  });

  factory AttendanceUpdateModel.fromJson(Map<String, dynamic> json) {
    return AttendanceUpdateModel(
      request: json['Request'] != null
          ? AttendanceRequest.fromJson(json['Request'])
          : null,
      staff: json['Staff'] != null ? Staff.fromJson(json['Staff']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Request': request?.toJson(),
      'Staff': staff?.toJson(),
    };
  }
}

class AttendanceRequest {
  final int? id;
  final int? staffId;
  final int? approverId;
  final DateTime? date;
  final String? reason;
  final String? status;
  final DateTime? createdOn;
  final String? guid;
  final String? comment;

  AttendanceRequest({
    this.id,
    this.staffId,
    this.approverId,
    this.date,
    this.reason,
    this.status,
    this.createdOn,
    this.guid,
    this.comment,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      id: json['Id'] as int?,
      staffId: json['StaffId'] as int?,
      approverId: json['ApproverId'] as int?,
      date: json['Date'] != null ? DateTime.tryParse(json['Date']) : null,
      reason: json['Reason'] as String?,
      status: json['Status'] as String?,
      createdOn:
          json['CreatedOn'] != null ? DateTime.tryParse(json['CreatedOn']) : null,
      guid: json['GUID'] as String?,
      comment: json['Comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'StaffId': staffId,
      'ApproverId': approverId,
      'Date': date?.toIso8601String(),
      'Reason': reason,
      'Status': status,
      'CreatedOn': createdOn?.toIso8601String(),
      'GUID': guid,
      'Comment': comment,
    };
  }
}

class Staff {
  final String? name;
  final String? empCode;
  final String? email;

  Staff({
    this.name,
    this.empCode,
    this.email,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      name: json['Name'] as String?,
      empCode: json['EmpCode'] as String?,
      email: json['Email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'EmpCode': empCode,
      'Email': email,
    };
  }
}
