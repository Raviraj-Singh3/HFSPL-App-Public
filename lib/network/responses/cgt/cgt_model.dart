class CGTModel {
  String? cgtid;
  String? groupid;
  String? group;
  String? cgtday1;
  String? cgtday2;
  String? cgtday3;
  String? pregrtday;
  String? grtday;
  String? cgtday1done;
  String? cgtday2done;
  String? cgtday3done;
  String? pregrtdaydone;
  String? grtdaydone;
  String? feid;
  String? isSync;
  dynamic members; // Updated from Null to dynamic for flexibility
  int? status;

  CGTModel({
    this.cgtid,
    this.groupid,
    this.group,
    this.cgtday1,
    this.cgtday2,
    this.cgtday3,
    this.pregrtday,
    this.grtday,
    this.cgtday1done,
    this.cgtday2done,
    this.cgtday3done,
    this.pregrtdaydone,
    this.grtdaydone,
    this.feid,
    this.isSync,
    this.members,
    this.status,
  });

  CGTModel.fromJson(Map<String, dynamic> json) {
    cgtid = json['cgtid'];
    groupid = json['groupid'];
    group = json['group'];
    cgtday1 = json['cgtday1'];
    cgtday2 = json['cgtday2'];
    cgtday3 = json['cgtday3'];
    pregrtday = json['pregrtday'];
    grtday = json['grtday'];
    cgtday1done = json['cgtday1done'];
    cgtday2done = json['cgtday2done'];
    cgtday3done = json['cgtday3done'];
    pregrtdaydone = json['pregrtdaydone'];
    grtdaydone = json['grtdaydone'];
    feid = json['feid'];
    isSync = json['isSync'];
    members =
        json['members']; // Keeping members dynamic in case it's more than null
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cgtid'] = cgtid;
    data['groupid'] = groupid;
    data['group'] = group;
    data['cgtday1'] = cgtday1;
    data['cgtday2'] = cgtday2;
    data['cgtday3'] = cgtday3;
    data['pregrtday'] = pregrtday;
    data['grtday'] = grtday;
    data['cgtday1done'] = cgtday1done;
    data['cgtday2done'] = cgtday2done;
    data['cgtday3done'] = cgtday3done;
    data['pregrtdaydone'] = pregrtdaydone;
    data['grtdaydone'] = grtdaydone;
    data['feid'] = feid;
    data['isSync'] = isSync;
    data['members'] = members;
    data['status'] = status;
    return data;
  }

  // Override the toString method
  @override
  String toString() {
    return 'CGTModel{cgtid: $cgtid, groupid: $groupid, group: $group, '
        'cgtday1: $cgtday1, cgtday2: $cgtday2, cgtday3: $cgtday3, '
        'pregrtday: $pregrtday, grtday: $grtday, cgtday1done: $cgtday1done, '
        'cgtday2done: $cgtday2done, cgtday3done: $cgtday3done, '
        'pregrtdaydone: $pregrtdaydone, grtdaydone: $grtdaydone, feid: $feid, '
        'isSync: $isSync, members: $members, status: $status}';
  }
}
