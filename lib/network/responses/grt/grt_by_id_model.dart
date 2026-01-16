
class GRTById {
  int? memberCgtId;
  int? groupCgtId;
  int? centerId;
  int? groupId;
  int? memberId;
  int? feId;
  int? branchId;
  String? branchName;
  String? feName;
  String? centerName;
  String? groupName;
  String? memberName;
  String? spouseName;
  String? nomineeName;
  int? phoneNumber;
  double? eligibleAmount;
  double? sactionAmount;
  String? loanPurpose;
  bool? attDay1;
  bool? attDay2;
  bool? attDay3;
  bool? attGrt;
  bool? grtPass;
  DateTime? cgtDay1;
  DateTime? cgtDay2;
  DateTime? cgtDay3;
  DateTime? grtDay;
  DateTime? cgtDay1Done;
  DateTime? cgtDay2Done;
  DateTime? cgtDay3Done;
  DateTime? grtDayDone;
  bool? kycStatus;
  int? grtType;
  int? status;
  bool? isDone;
  String? bankAcNo;
  String? bankIFSC;
  bool? bankCheck;
  DateTime? hmupdate;
  DateTime? preGrtDay;
  DateTime? preGrtDayDone;
  String? hmDate;
  bool? hmExpired;
  int? hmExpireDaysRemaining;
  String? nameInBank;

  GRTById({
    this.memberCgtId,
    this.groupCgtId,
    this.centerId,
    this.groupId,
    this.memberId,
    this.feId,
    this.branchId,
    this.branchName,
    this.feName,
    this.centerName,
    this.groupName,
    this.memberName,
    this.spouseName,
    this.nomineeName,
    this.phoneNumber,
    this.eligibleAmount,
    this.sactionAmount,
    this.loanPurpose,
    this.attDay1,
    this.attDay2,
    this.attDay3,
    this.attGrt,
    this.grtPass,
    this.cgtDay1,
    this.cgtDay2,
    this.cgtDay3,
    this.grtDay,
    this.cgtDay1Done,
    this.cgtDay2Done,
    this.cgtDay3Done,
    this.grtDayDone,
    this.kycStatus,
    this.grtType,
    this.status,
    this.isDone,
    this.bankAcNo,
    this.bankIFSC,
    this.bankCheck,
    this.hmupdate,
    this.preGrtDay,
    this.preGrtDayDone,
    this.hmDate,
    this.hmExpired,
    this.hmExpireDaysRemaining,
    this.nameInBank
  });

  // Factory method to create an instance from a JSON object
  factory GRTById.fromJson(Map<String, dynamic> json) {
    return GRTById(
      memberCgtId: json['MemberCgtId'],
      groupCgtId: json['GroupCgtId'],
      centerId: json['CenterId'],
      groupId: json['Groupid'],
      memberId: json['MemberId'],
      feId: json['FeId'],
      branchId: json['BranchId'],
      branchName: json['BranchName'],
      feName: json['FeName'],
      centerName: json['CenterName'],
      groupName: json['GroupName'],
      memberName: json['MemberName'],
      spouseName: json['SpouseName'],
      nomineeName: json['NomineeName'],
      phoneNumber: json['PhoneNumber'],
      eligibleAmount: (json['EligibleAmount'] as num?)?.toDouble(),
      sactionAmount: (json['SactionAmount'] as num?)?.toDouble(),
      loanPurpose: json['LoanPurpose'],
      attDay1: json['AttDay1'],
      attDay2: json['AttDay2'],
      attDay3: json['AttDay3'],
      attGrt: json['AttGrt'],
      grtPass: json['GrtPass'],
      cgtDay1: json['CgtDay1'] != null ? DateTime.parse(json['CgtDay1']) : null,
      cgtDay2: json['CgtDay2'] != null ? DateTime.parse(json['CgtDay2']) : null,
      cgtDay3: json['CgtDay3'] != null ? DateTime.parse(json['CgtDay3']) : null,
      grtDay: json['GrtDay'] != null ? DateTime.parse(json['GrtDay']) : null,
      cgtDay1Done: json['CgtDay1Done'] != null ? DateTime.parse(json['CgtDay1Done']) : null,
      cgtDay2Done: json['CgtDay2Done'] != null ? DateTime.parse(json['CgtDay2Done']) : null,
      cgtDay3Done: json['CgtDay3Done'] != null ? DateTime.parse(json['CgtDay3Done']) : null,
      grtDayDone: json['GrtDayDone'] != null ? DateTime.parse(json['GrtDayDone']) : null,
      kycStatus: json['KycStatus'],
      grtType: json['grtType'],
      status: json['Status'],
      isDone: json['IsDone'],
      bankAcNo: json['BankAcNo'],
      bankIFSC: json['BankIFSC'],
      bankCheck: json['BankCheck'],
      hmupdate: json['hmupdate'] != null ? DateTime.parse(json['hmupdate']) : null,
      preGrtDay: json['PreGrtDay'] != null ? DateTime.parse(json['PreGrtDay']) : null,
      preGrtDayDone: json['PreGrtDayDone'] != null ? DateTime.parse(json['PreGrtDayDone']) : null,
      hmDate: json['HmDate'],
      hmExpired: json['HmExpired'],
      hmExpireDaysRemaining: json['HmExpireDaysRemaining'],
      nameInBank: json['NameInBank'],
    );
  }

  // Method to convert a list of JSON objects to a list of GRTById instances
  static List<GRTById> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => GRTById.fromJson(json)).toList();
  }
}
