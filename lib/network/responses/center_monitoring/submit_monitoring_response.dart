class SubmitMonitoringResponse {
  final bool success;
  final String message;
  final int? monitoringId;

  SubmitMonitoringResponse({
    required this.success,
    required this.message,
    this.monitoringId,
  });

  factory SubmitMonitoringResponse.fromJson(Map<String, dynamic> json) {
    return SubmitMonitoringResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      monitoringId: json['monitoringId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'monitoringId': monitoringId,
    };
  }
}
