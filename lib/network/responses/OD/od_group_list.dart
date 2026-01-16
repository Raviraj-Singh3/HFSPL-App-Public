
import 'dart:convert';

class OdGroupList {
  final String groupName;
  final List<OdMember> members;
  final int memberCount;

  OdGroupList({
    required this.groupName,
    required this.members,
    required this.memberCount,
  });

  factory OdGroupList.fromJson(Map<String, dynamic> json) {
    return OdGroupList(
      groupName: json['GroupName'],
      members: (json['Members'] as List)
          .map((member) => OdMember.fromJson(member))
          .toList(),
      memberCount: json['MemberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GroupName': groupName,
      'Members': members.map((member) => member.toJson()).toList(),
      'MemberCount': memberCount,
    };
  }

  /// Parses a list of JSON objects into a list of OdGroupList instances.
  static List<OdGroupList> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => OdGroupList.fromJson(json)).toList();
  }
}

class OdMember {
  final String loanNo;
  final double loanAmt;
  final String loanDate;
  final double intrAmt;
  final double intrRate;
  final int misId;
  final String memberName;
  final String spouse;
  final String mobile;
  final String odStartDate;
  final String lastTransactionDate;
  final double totAmtPayable;
  final double intrAmtPayable;
  final double prAmtPayable;
  final double totalOS;
  final double interestOS;
  final double principleOS;
  final int duesDays;

  OdMember({
    required this.loanNo,
    required this.loanAmt,
    required this.loanDate,
    required this.intrAmt,
    required this.intrRate,
    required this.misId,
    required this.memberName,
    required this.spouse,
    required this.mobile,
    required this.odStartDate,
    required this.lastTransactionDate,
    required this.totAmtPayable,
    required this.intrAmtPayable,
    required this.prAmtPayable,
    required this.totalOS,
    required this.interestOS,
    required this.principleOS,
    required this.duesDays,
  });

  factory OdMember.fromJson(Map<String, dynamic> json) {
  try {
    return OdMember(
      loanNo: json['LoanNo'] ?? '',
      loanAmt: (json['LoanAmt'] ?? 0).toDouble(),
      loanDate: json['LoanDate'] ?? '',
      intrAmt: (json['IntrAmt'] ?? 0).toDouble(),
      intrRate: (json['IntrRate'] ?? 0).toDouble(),
      misId: json['MisId'] ?? 0,
      memberName: json['MemberName'] ?? '',
      spouse: json['Spouse'] ?? '',
      mobile: json['Mobile'] ?? '',
      odStartDate: json['Od_Start_Date'] ?? '',
      lastTransactionDate: json['LastTransactionDate'] ?? '',
      totAmtPayable: (json['TotAmtPayble'] ?? 0).toDouble(),
      intrAmtPayable: (json['IntrAmtPayble'] ?? 0).toDouble(),
      prAmtPayable: (json['PrAmtPayble'] ?? 0).toDouble(),
      totalOS: (json['TotalOS'] ?? 0).toDouble(),
      interestOS: (json['InterestOS'] ?? 0).toDouble(),
      principleOS: (json['PincipleOS'] ?? 0).toDouble(),
      duesDays: json['DuesDays'] ?? 0,
    );
  } catch (e) {
    print('Error parsing OdMember: $e');
    throw Exception('Failed to parse OdMember');
  }
}

  Map<String, dynamic> toJson() {
    return {
      'LoanNo': loanNo,
      'LoanAmt': loanAmt,
      'LoanDate': loanDate,
      'IntrAmt': intrAmt,
      'IntrRate': intrRate,
      'MisId': misId,
      'MemberName': memberName,
      'Spouse': spouse,
      'Mobile': mobile,
      'Od_Start_Date': odStartDate,
      'LastTransactionDate': lastTransactionDate,
      'TotAmtPayble': totAmtPayable,
      'IntrAmtPayble': intrAmtPayable,
      'PrAmtPayble': prAmtPayable,
      'TotalOS': totalOS,
      'InterestOS': interestOS,
      'PincipleOS': principleOS,
      'DuesDays': duesDays,
    };
  }
}
