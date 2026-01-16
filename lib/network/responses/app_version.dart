class AppVersionResp {
  final String dateTime;
  final bool? showPopup;
  final int? id;
  final String? versionCode;
  final int? type;
  final bool? status;
  final String? versionTitle;
  final String? versionMessage;
  final bool? isUpdateRequired;

  AppVersionResp({
    required this.dateTime,
    this.showPopup,
    this.id,
    this.versionCode,
    this.type,
    this.status,
    this.versionTitle,
    this.versionMessage,
    this.isUpdateRequired,
  });

  factory AppVersionResp.fromJson(Map<String, dynamic> json) {
    return AppVersionResp(
      dateTime: json['dateTime'],
      showPopup: json['showPopup'],
      id: json['Id'],
      versionCode: json['VersionCode'],
      type: json['type'],
      status: json['Status'],
      versionTitle: json['VersionTitle'],
      versionMessage: json['VersionMessage'],
      isUpdateRequired: json['isUpdateRequired'],
    );
  }
}