class DDEAssignedModel {
  int? ddeScheduleId;
  int? snapshotId;
  int? clientId;
  String? name;
  int? phone;
  String? ddeDate;
  String? address;

  DDEAssignedModel({
    this.ddeScheduleId,
    this.snapshotId,
    this.clientId,
    this.name,
    this.phone,
    this.ddeDate,
    this.address,
  });

  factory DDEAssignedModel.fromJson(Map<String, dynamic> json) {
    return DDEAssignedModel(
      ddeScheduleId: json['DDEScheduleId'] as int?,
      snapshotId: json['SnapshotId'] as int?,
      clientId: json['ClientId'] as int?,
      name: json['Name'] as String?,
      phone: json['Phone'] as int?,
      ddeDate: json['DDEDate'] as String?,
      address: json['Address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ddeScheduleId': ddeScheduleId,
      'snapshotId': snapshotId,
      'clientId': clientId,
      'name': name,
      'phone': phone,
      'ddeDate': ddeDate,
      'address': address,
    };
  }
}
