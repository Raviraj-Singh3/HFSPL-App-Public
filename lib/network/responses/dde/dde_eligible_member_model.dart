class DDEEligibleMemberModel {
  int? snapshotId;
  int? clientId;
  String? name;
  int? phone;
  String? address;
  double? eligibleAmount;
  String? crifCheckDate;

  DDEEligibleMemberModel({
    this.snapshotId,
    this.clientId,
    this.name,
    this.phone,
    this.address,
    this.eligibleAmount,
    this.crifCheckDate,
  });

  factory DDEEligibleMemberModel.fromJson(Map<String, dynamic> json) {
    return DDEEligibleMemberModel(
      snapshotId: json['SnapshotId'] as int?,
      clientId: json['ClientId'] as int?,
      name: json['Name'] as String?,
      phone: json['Phone'] as int?,
      address: json['Address'] as String?,
      eligibleAmount: (json['EligibleAmount'] as num?)?.toDouble(),
      crifCheckDate: json['CRIFCheckDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snapshotId': snapshotId,
      'clientId': clientId,
      'name': name,
      'phone': phone,
      'address': address,
      'eligibleAmount': eligibleAmount,
      'crifCheckDate': crifCheckDate,
    };
  }
}
