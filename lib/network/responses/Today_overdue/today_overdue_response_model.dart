class TodayOverdueModel {
  final int groupId;
  final String groupName;
  final String collectionTime;
  final List<Member> members;

  TodayOverdueModel({
    required this.groupId,
    required this.groupName,
    required this.collectionTime,
    required this.members,
  });

  factory TodayOverdueModel.fromJson(Map<String, dynamic> json) {
    return TodayOverdueModel(
      groupId: json['GroupId'] as int,
      groupName: json['GroupName'] as String,
      collectionTime: json['CollectionTime'] as String,
      members: (json['Members'] as List)
          .map((item) => Member.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'GroupName': groupName,
      'CollectionTime': collectionTime,
      'Members': members.map((e) => e.toJson()).toList(),
    };
  }

  static List<TodayOverdueModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => TodayOverdueModel.fromJson(item)).toList();
  }
}

class Member {
  final int mId;
  final int clientId;
  final String? name;
  final String? relativeName;
  final int? memberPhone1;
  final int? memberPhone2;
  final int? installment;
  final double? demand;

  Member({
    required this.mId,
    required this.clientId,
    this.name,
    this.relativeName,
    this.memberPhone1,
    this.memberPhone2,
    this.installment,
    this.demand,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      mId: json['M_id'] as int,
      clientId: json['Client_Id'] as int,
      name: json['Name'] as String?,
      relativeName: json['RelativeName'] as String?,
      memberPhone1: json['MemberPhone1'] as int?,
      memberPhone2: json['MemberPhone2'] as int?,
      installment: json['Installment'] as int?,
      demand: json['Demand'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'M_id': mId,
      'Client_Id': clientId,
      'Name': name,
      'RelativeName': relativeName,
      'MemberPhone1': memberPhone1,
      'MemberPhone2': memberPhone2,
      'Installment': installment,
      'Demand': demand,
    };
  }
}
