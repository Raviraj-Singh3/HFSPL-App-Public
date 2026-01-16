class RequestPostCGT {
  List<RequestPostCGTItem> items;

  RequestPostCGT({required this.items});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class RequestPostCGTItem {
  String? cgtid;
  String? cgtday1;
  String? cgtday1done; // Added
  String? cgtday2; // Added
  String? cgtday2done; // Added
  String? cgtday3; // Added
  String? cgtday3done; // Added
  String? feid;
  String? groupid;
  String? group;
  String? pregrtday; // Added
  String? grtday; // Added
  String? pregrtdaydone; // Added
  String? grtdaydone; // Added
  String? isSync;
  List<Member> members;

  RequestPostCGTItem({
    this.cgtid,
    this.cgtday1,
    this.cgtday1done, // Added
    this.cgtday2, // Added
    this.cgtday2done, // Added
    this.cgtday3, // Added
    this.cgtday3done, // Added
    this.feid,
    this.groupid,
    this.group,
    this.pregrtday, // Added
    this.grtday, // Added
    this.pregrtdaydone, // Added
    this.grtdaydone, // Added
    this.isSync,
    required this.members,
  });

  Map<String, dynamic> toJson() {
    return {
      'cgtid': cgtid,
      'cgtday1': cgtday1,
      'cgtday1done': cgtday1done, // Added
      'cgtday2': cgtday2, // Added
      'cgtday2done': cgtday2done, // Added
      'cgtday3': cgtday3, // Added
      'cgtday3done': cgtday3done, // Added
      'feid': feid,
      'groupid': groupid,
      'group': group,
      'pregrtday': pregrtday, // Added
      'grtday': grtday, // Added
      'pregrtdaydone': pregrtdaydone, // Added
      'grtdaydone': grtdaydone, // Added
      'isSync': isSync,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}

class Member {
  String? name;
  String? vid;
  String? cgtmemberid;
  String? relative;
  String? phone;
  int? otp;
  int? otpEntered;
  String? day1; // Added
  String? day2; // Added
  String? day3; // Added
  String? pregrt; // Added
  String? grt; // Added
  bool? isDropped; // Added

  Member({
    this.name,
    this.vid,
    this.cgtmemberid,
    this.relative,
    this.phone,
    this.otp,
    this.otpEntered,
    this.day1, // Added
    this.day2, // Added
    this.day3, // Added
    this.pregrt, // Added
    this.grt, // Added
    this.isDropped, // Added
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vid': vid,
      'cgtmemberid': cgtmemberid,
      'relative': relative,
      'phone': phone,
      'otp': otp,
      'otpEntered': otpEntered,
      'day1': day1, // Added
      'day2': day2, // Added
      'day3': day3, // Added
      'pregrt': pregrt, // Added
      'grt': grt, // Added
      'isDropped': isDropped, // Added
    };
  }
}
