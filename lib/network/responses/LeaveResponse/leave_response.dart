class LeaveModelResponse {
  double? balance;
  double? usedLeave;
  double? carryForwardedLeave;
  int? lid;
  String? leaveName;
  String? leaveShortName;
  int? quota;
  bool? isProofRequired;
  String? cDate; // Nullable date as a string
  int? year;
  bool? status;

  LeaveModelResponse({
    this.balance,
    this.usedLeave,
    this.carryForwardedLeave,
    this.lid,
    this.leaveName,
    this.leaveShortName,
    this.quota,
    this.isProofRequired,
    this.cDate,
    this.year,
    this.status,
  });

  // Factory method to create a LeaveModel object from JSON
  factory LeaveModelResponse.fromJson(Map<String, dynamic> json) {
    return LeaveModelResponse(
      balance: (json['Balance'] as num?)?.toDouble(),
      usedLeave: (json['UsedLeave'] as num?)?.toDouble(),
      carryForwardedLeave: (json['CarryForwardedLeave'] as num?)?.toDouble(),
      lid: json['LID'] as int?,
      leaveName: json['LEAVE_NAME'] as String?,
      leaveShortName: json['LEAVE_SHORT_NAME'] as String?,
      quota: json['Quota'] as int?,
      isProofRequired: json['IsProofRequired'] as bool?,
      cDate: json['cDate'] as String?, // Directly as string
      year: json['YEAR'] as int?,
      status: json['Status'] as bool?,
    );
  }

  // Method to convert a LeaveModel object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'Balance': balance,
      'UsedLeave': usedLeave,
      'CarryForwardedLeave': carryForwardedLeave,
      'LID': lid,
      'LEAVE_NAME': leaveName,
      'LEAVE_SHORT_NAME': leaveShortName,
      'Quota': quota,
      'IsProofRequired': isProofRequired,
      'cDate': cDate,
      'YEAR': year,
      'Status': status,
    };
  }

  // Method to convert a list of JSON objects into a list of LeaveModel objects
  static List<LeaveModelResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => LeaveModelResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
