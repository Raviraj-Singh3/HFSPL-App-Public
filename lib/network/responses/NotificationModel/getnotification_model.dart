class GetNotificationModel {
  final String? title;
  final String? body;
  final int? notificationId;
  final String? guid;
  final int? notificationType;

  GetNotificationModel({
    this.title,
    this.body,
    this.notificationId,
    this.guid,
    this.notificationType,
  });

  factory GetNotificationModel.fromJson(Map<String, dynamic> json) {
    return GetNotificationModel(
      title: json['Title'] as String?,
      body: json['Body'] as String?,
      notificationId: json['NotificationId'] as int?,
      guid: json['guid'] as String?,
      notificationType: json['notificationType'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Title": title,
      "Body": body,
      "NotificationId": notificationId,
      "guid": guid,
      "notificationType": notificationType,
    };
  }

  static List<GetNotificationModel> listFromJson(List<dynamic> list) {
    return list.map((e) => GetNotificationModel.fromJson(e)).toList();
  }
}
