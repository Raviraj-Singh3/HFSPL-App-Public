class MobileCheckResponse {
  final String success;
  final String message;

  MobileCheckResponse({
    required this.success,
    required this.message,
  });

  factory MobileCheckResponse.fromJson(Map<String, dynamic> json) {
    return MobileCheckResponse(
      success: json['success'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
