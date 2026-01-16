class HmModel {
  String? groupid;
  String? groupname;
  List<PassMember>? passmembers;
  int? cgt_status;

  HmModel({
    this.groupid,
    this.groupname,
    this.passmembers,
    this.cgt_status,
  });

  factory HmModel.fromJson(Map<String, dynamic> json) {
    return HmModel(
      groupid: json['groupid'] as String?,
      groupname: json['groupname'] as String?,
      passmembers: json['passmembers'] != null
          ? (json['passmembers'] as List)
              .map((item) => PassMember.fromJson(item))
              .toList()
          : [],
      cgt_status: json['cgt_status'] as int?,
    );
  }
}

class PassMember {
  String? vid;
  String? membername;
  String? spousename;
  double? elamt;
  int? mp;
  bool? editableKYC;
  int? phone;
  int? otp;
  int? otpEntered;

  PassMember({
    this.vid,
    this.membername,
    this.spousename,
    this.elamt,
    this.mp,
    this.editableKYC,
    this.phone,
    this.otp,
    this.otpEntered,
  });

  factory PassMember.fromJson(Map<String, dynamic> json) {
    return PassMember(
      vid: json['vid'] as String?,
      membername: json['membername'] as String?,
      spousename: json['spousename'] as String?,
      elamt: (json['elamt'] as num?)?.toDouble(),
      mp: json['mp'] as int?,
      editableKYC: json['editableKYC'] as bool?,
      phone: json['phone'] as int?,
      otp: json['otp'] as int?,
      otpEntered: json['otpEntered'] as int?,
    );
  }
}
