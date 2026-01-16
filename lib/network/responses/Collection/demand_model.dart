
class Member {
  String? bank;
  int? clientId;
  int? memberId;
  String? name;
  String? relativeName;
  int? memberPhone1;
  String? loanNumber;
  int? shgId;
  DateTime? collectionDate;
  int? installment;
  double? emi;
  double? interest;
  double? principal;
  double? demand;
  double? overdue;
  double? penalty;
  double? intRate;
  DateTime? disDate;
  double? disAmt;
  bool? clientPhotoEnable;

  Member({
    this.bank,
    this.clientId,
    this.memberId,
    this.name,
    this.relativeName,
    this.memberPhone1,
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
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      bank: json['Bank'],
      clientId: json['Client_Id'],
      memberId: json['M_id'],
      name: json['Name'],
      relativeName: json['RelativeName'],
      memberPhone1: json['MemberPhone1'],
      loanNumber: json['LoanNumber'],
      shgId: json['shg_id'],
      collectionDate: json['CollectionDate'] != null ? DateTime.parse(json['CollectionDate']) : null,
      installment: json['Installment'],
      emi: (json['Emi'] as num?)?.toDouble(),
      interest: (json['Interest'] as num?)?.toDouble(),
      principal: (json['Principal'] as num?)?.toDouble(),
      demand: (json['Demand'] as num?)?.toDouble(),
      overdue: (json['Overdue'] as num?)?.toDouble(),
      penalty: (json['Penalty'] as num?)?.toDouble(),
      intRate: (json['INT_RATE'] as num?)?.toDouble(),
      disDate: json['DIS_DATE'] != null ? DateTime.parse(json['DIS_DATE']) : null,
      disAmt: (json['DIS_AMT'] as num?)?.toDouble(),
      clientPhotoEnable: json['ClientPhotoEnable'],
    );
  }

  static List<Member> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Member.fromJson(json)).toList();
  }
}

class GroupDemandData {
  bool? enableGroupPhoto;
  String? idSelectText;
  String? idHintText;
  bool? idRequired;
  List<Member>? members;

  GroupDemandData({
    this.enableGroupPhoto,
    this.idSelectText,
    this.idHintText,
    this.idRequired,
    this.members,
  });

  factory GroupDemandData.fromJson(Map<String, dynamic> json) {
    return GroupDemandData(
      enableGroupPhoto: json['EnableGroupPhoto'],
      idSelectText: json['IdSelectText'],
      idHintText: json['IdHintText'],
      idRequired: json['IdRequired'],
      members: json['Members'] != null
          ? Member.listFromJson(json['Members'])
          : [],
    );
  }
}
