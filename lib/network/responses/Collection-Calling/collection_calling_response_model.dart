class CollectionCallingResponse {
  final bool? isLeader;
  final bool? isCoLeader;
  final bool? haveSmartPhone;
  final String? feName;
  final String? groupName;
  final String? memberAddress;
  final String? finalRemark;
  final String? finalRemarkStatus;
  final String? clientRemark;
  final String? updateBranch;
  final String? updateTel;
  final String? bank;
  final int? clientId;
  final int? mId;
  final String? name;
  final String? relativeName;
  final int? memberPhone1;
  final String? memberPhone2;
  final String? loanNumber;
  final int? shgId;
  final String? collectionDate;
  final int? installment;
  final double? emi;
  final double? interest;
  final double? principal;
  final double? demand;
  final double? overdue;
  final double? penalty;
  final double? intRate;
  final String? disDate;
  final double? disAmt;
  final bool? clientPhotoEnable;
  final List<int>? updatedNumbers;
  final int? firstFilledNumber;

  CollectionCallingResponse({
    this.isLeader,
    this.isCoLeader,
    this.haveSmartPhone,
    this.feName,
    this.groupName,
    this.memberAddress,
    this.finalRemark,
    this.finalRemarkStatus,
    this.clientRemark,
    this.updateBranch,
    this.updateTel,
    this.bank,
    this.clientId,
    this.mId,
    this.name,
    this.relativeName,
    this.memberPhone1,
    this.memberPhone2,
    this.loanNumber,
    this.shgId,
    this.collectionDate,
    this.installment,
    this.emi,
    this.interest,
    this.principal,
    this.demand,
    this.overdue,
    this.penalty,
    this.intRate,
    this.disDate,
    this.disAmt,
    this.clientPhotoEnable,
    this.updatedNumbers,
    this.firstFilledNumber,
  });

  factory CollectionCallingResponse.fromJson(Map<String, dynamic> json) {
    return CollectionCallingResponse(
      isLeader: json['isLeader'],
      isCoLeader: json['isCoLeader'],
      haveSmartPhone: json['haveSmartPhone'],
      feName: json['FeName'],
      groupName: json['GroupName'],
      memberAddress: json['MemberAddress'],
      finalRemark: json['finalremark'],
      finalRemarkStatus: json['finalremarkstatus'],
      clientRemark: json['clientRemark'],
      updateBranch: json['UPDATEBRANCH'],
      updateTel: json['UPDATETEL'],
      bank: json['Bank'],
      clientId: json['Client_Id'],
      mId: json['M_id'],
      name: json['Name'],
      relativeName: json['RelativeName'],
      memberPhone1: json['MemberPhone1'],
      memberPhone2: json['MemberPhone2'],
      loanNumber: json['LoanNumber'],
      shgId: json['shg_id'],
      collectionDate: json['CollectionDate'],
      installment: json['Installment'],
      emi: (json['Emi'] as num?)?.toDouble(),
      interest: (json['Interest'] as num?)?.toDouble(),
      principal: (json['Principal'] as num?)?.toDouble(),
      demand: (json['Demand'] as num?)?.toDouble(),
      overdue: (json['Overdue'] as num?)?.toDouble(),
      penalty: (json['Penalty'] as num?)?.toDouble(),
      intRate: (json['INT_RATE'] as num?)?.toDouble(),
      disDate: json['DIS_DATE'],
      disAmt: (json['DIS_AMT'] as num?)?.toDouble(),
      clientPhotoEnable: json['ClientPhotoEnable'],
      updatedNumbers: (json['UpdatedNumbers'] as List<dynamic>?)?.map((e) => e as int).toList(),
      firstFilledNumber: json['FirstFilledNumber'],
    );
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
      'MemberPhone2': memberPhone2,
      'LoanNumber': loanNumber,
      'shg_id': shgId,
      'CollectionDate': collectionDate,
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
      'UpdatedNumbers': updatedNumbers,
      'FirstFilledNumber': firstFilledNumber,
    };
  }

  static List<CollectionCallingResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CollectionCallingResponse.fromJson(json))
        .toList();
  }
}
