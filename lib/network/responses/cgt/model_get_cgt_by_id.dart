class CGTById {
  String? cgtmemberid;
  String? vid;
  String? name;
  String? relative;
  String? day1;
  String? day2;
  String? day3;
  String? pregrt;
  String? grt;
  String? pregrtpass;
  String? pass;
  int? phone;
  int? otp;
  int? otpEntered;
  String? hmDate;
  bool? hmExpired;
  bool? isDropped;
  int? hmExpireDaysRemaining;

  CGTById(
      {this.cgtmemberid,
      this.vid,
      this.name,
      this.relative,
      this.day1,
      this.day2,
      this.day3,
      this.pregrt,
      this.grt,
      this.pregrtpass,
      this.pass,
      this.phone,
      this.otp,
      this.otpEntered,
      this.hmDate,
      this.hmExpired,
      this.isDropped,
      this.hmExpireDaysRemaining});

  factory CGTById.fromMap(Map<String, dynamic> data) => CGTById(
        cgtmemberid: data['cgtmemberid'] as String?,
        vid: data['vid'] as String?,
        name: data['name'] as String?,
        relative: data['relative'] as String?,
        day1: data['day1'] as String?,
        day2: data['day2'] as String?,
        day3: data['day13'] as String?,
        pregrt: data['pregrt'] as String?,
        grt: data['grt'] as String?,
        pregrtpass: data['pregrtpass'] as String?,
        pass: data['pass'] as String?,
        phone: data['phone'] as int?,
        otp: data['otp'] as int?,
        otpEntered: data['otpEntered'] as int?,
        hmDate: data['hmDate'] as String?,
        hmExpired: data['hmExpired'] as bool?,
        isDropped: data['isDropped'] as bool?,
        hmExpireDaysRemaining: data['hmExpireDaysRemaining'] as int?,

        // groupList: CGTById.listFromJson(data['GroupList']),
      );

  CGTById.fromJson(Map<String, dynamic> json) {
    cgtmemberid = json['cgtmemberid'];
    vid = json['vid'];
    name = json['name'];
    relative = json['relative'];
    day1 = json['day1'];
    day2 = json['day2'];
    day3 = json['day3'];
    pregrt = json['pregrt'];
    grt = json['grt'];
    pregrtpass = json['pregrtpass'];
    pass = json['pass'];
    phone = json['phone'];
    otp = json['otp'];
    otpEntered = json['otpEntered'];
    hmDate = json['HmDate'];
    hmExpired = json['HmExpired'];
    isDropped = json['isDropped'];
    hmExpireDaysRemaining = json['HmExpireDaysRemaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cgtmemberid'] = this.cgtmemberid;
    data['vid'] = this.vid;
    data['name'] = this.name;
    data['relative'] = this.relative;
    data['day1'] = this.day1;
    data['day2'] = this.day2;
    data['day3'] = this.day3;
    data['pregrt'] = this.pregrt;
    data['grt'] = this.grt;
    data['pregrtpass'] = this.pregrtpass;
    data['pass'] = this.pass;
    data['phone'] = this.phone;
    data['otp'] = this.otp;
    data['otpEntered'] = this.otpEntered;
    data['HmDate'] = this.hmDate;
    data['HmExpired'] = this.hmExpired;
    data['isDropped'] = this.isDropped;
    data['HmExpireDaysRemaining'] = this.hmExpireDaysRemaining;
    return data;
  }

  static List<CGTById> listFromJson(List<dynamic> jsonData) {
    return jsonData.map((json) => CGTById.fromMap(json)).toList();
  }
}
