class VerificationEligibleMemberModel {
  final int? ddeScheduleId;
  final int? snapshotId;
  final int? clientId;
  final String? name;
  final int? phone;
  final String? ddeCompletionDate;
  final String? feName;
  final String? ddeNotes;

  VerificationEligibleMemberModel({
    this.ddeScheduleId,
    this.snapshotId,
    this.clientId,
    this.name,
    this.phone,
    this.ddeCompletionDate,
    this.feName,
    this.ddeNotes,
  });

  factory VerificationEligibleMemberModel.fromJson(Map<String, dynamic> json) {
    return VerificationEligibleMemberModel(
      ddeScheduleId: json['DDEScheduleId'] as int?,
      snapshotId: json['SnapshotId'] as int?,
      clientId: json['ClientId'] as int?,
      name: json['Name'] as String?,
      phone: json['Phone'] as int?,
      ddeCompletionDate: json['DDECompletionDate'] as String?,
      feName: json['FEName'] as String?,
      ddeNotes: json['DDENotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DDEScheduleId': ddeScheduleId,
      'SnapshotId': snapshotId,
      'ClientId': clientId,
      'Name': name,
      'Phone': phone,
      'DDECompletionDate': ddeCompletionDate,
      'FEName': feName,
      'DDENotes': ddeNotes,
    };
  }

  /// Parse a list of VerificationEligibleMemberModel from JSON array
  static List<VerificationEligibleMemberModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((item) => VerificationEligibleMemberModel.fromJson(item))
        .toList();
  }
}
