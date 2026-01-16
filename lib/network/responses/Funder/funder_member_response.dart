class FunderMemberResponse {
  final bool isLeader;
  final bool isCoLeader;
  final bool haveSmartPhone;
  final String? feName;
  final String groupName;
  final String memberAddress;
  final String finalRemark;
  final String finalRemarkStatus;
  final String clientRemark;
  final String? updateBranch;
  final String? updateTel;
  final String? bank;
  final int clientId;
  final int mId;
  final String name;
  final String relativeName;
  final int memberPhone1;
  final String? loanNumber;
  final int shgId;
  final DateTime collectionDate;
  final double installment;
  final double emi;
  final double interest;
  final double principal;
  final double demand;
  final double overdue;
  final double penalty;
  final double intRate;
  final String? disDate;
  final double disAmt;
  final bool clientPhotoEnable;

  FunderMemberResponse({
    required this.isLeader,
    required this.isCoLeader,
    required this.haveSmartPhone,
    this.feName,
    required this.groupName,
    required this.memberAddress,
    required this.finalRemark,
    required this.finalRemarkStatus,
    required this.clientRemark,
    this.updateBranch,
    this.updateTel,
    this.bank,
    required this.clientId,
    required this.mId,
    required this.name,
    required this.relativeName,
    required this.memberPhone1,
    this.loanNumber,
    required this.shgId,
    required this.collectionDate,
    required this.installment,
    required this.emi,
    required this.interest,
    required this.principal,
    required this.demand,
    required this.overdue,
    required this.penalty,
    required this.intRate,
    this.disDate,
    required this.disAmt,
    required this.clientPhotoEnable,
  });

  factory FunderMemberResponse.fromJson(Map<String, dynamic> json) {
    return FunderMemberResponse(
      isLeader: json['isLeader'] as bool,
      isCoLeader: json['isCoLeader'] as bool,
      haveSmartPhone: json['haveSmartPhone'] as bool,
      feName: json['FeName'] as String?,
      groupName: json['GroupName'] as String,
      memberAddress: json['MemberAddress'] as String,
      finalRemark: json['finalremark'] as String,
      finalRemarkStatus: json['finalremarkstatus'] as String,
      clientRemark: json['clientRemark'] as String,
      updateBranch: json['UPDATEBRANCH'] as String?,
      updateTel: json['UPDATETEL'] as String?,
      bank: json['Bank'] as String?,
      clientId: json['Client_Id'] as int,
      mId: json['M_id'] as int,
      name: json['Name'] as String,
      relativeName: json['RelativeName'] as String,
      memberPhone1: json['MemberPhone1'] as int,
      loanNumber: json['LoanNumber'] as String?,
      shgId: json['shg_id'] as int,
      collectionDate: DateTime.parse(json['CollectionDate'] as String),
      installment: (json['Installment'] as num).toDouble(),
      emi: (json['Emi'] as num).toDouble(),
      interest: (json['Interest'] as num).toDouble(),
      principal: (json['Principal'] as num).toDouble(),
      demand: (json['Demand'] as num).toDouble(),
      overdue: (json['Overdue'] as num).toDouble(),
      penalty: (json['Penalty'] as num).toDouble(),
      intRate: (json['INT_RATE'] as num).toDouble(),
      disDate: json['DIS_DATE'] as String?,
      disAmt: (json['DIS_AMT'] as num).toDouble(),
      clientPhotoEnable: json['ClientPhotoEnable'] as bool,
    );
  }

  static List<FunderMemberResponse> listFromJson(List<dynamic> json) {
    return json.map((e) => FunderMemberResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'isLeader': isLeader,
      'isCoLeader': isCoLeader,
      'haveSmartPhone': haveSmartPhone,
      'FeName': feName,
      'GroupName': groupName,
      'MemberAddress': memberAddress,
      'finalremark': finalRemark,
      'finalremarkstatus': finalRemarkStatus,
      'clientRemark': clientRemark,
      'UPDATEBRANCH': updateBranch,
      'UPDATETEL': updateTel,
      'Bank': bank,
      'Client_Id': clientId,
      'M_id': mId,
      'Name': name,
      'RelativeName': relativeName,
      'MemberPhone1': memberPhone1,
      'LoanNumber': loanNumber,
      'shg_id': shgId,
      'CollectionDate': collectionDate.toIso8601String(),
      'Installment': installment,
      'Emi': emi,
      'Interest': interest,
      'Principal': principal,
      'Demand': demand,
      'Overdue': overdue,
      'Penalty': penalty,
      'INT_RATE': intRate,
      'DIS_DATE': disDate,
      'DIS_AMT': disAmt,
      'ClientPhotoEnable': clientPhotoEnable,
    };
  }
} 