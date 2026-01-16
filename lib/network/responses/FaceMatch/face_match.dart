class FaceMatchModel {
  final String? requestId;
  final Result? result;
  final int? statusCode;
  final String? statusMessage;

  FaceMatchModel({
    this.requestId,
    this.result,
    this.statusCode,
    this.statusMessage,
  });

  // JSON Parsing
  factory FaceMatchModel.fromJson(Map<String, dynamic> json) {
    return FaceMatchModel(
      requestId: json['requestId'] as String?,
      result: (json['result'] is Map<String, dynamic> && json['result']?.isNotEmpty == true)
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null, // Handle empty or null result
      statusCode: json['statusCode'] as int?,
      statusMessage: json['statusMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'result': result?.toJson(),
        'statusCode': statusCode,
        'statusMessage': statusMessage,
      };
}

class Result {
  final String? match;
  final double? matchScore;
  final String? reviewNeeded;
  final double? confidence;

  Result({
    this.match,
    this.matchScore,
    this.reviewNeeded,
    this.confidence,
  });

  // JSON Parsing
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      match: json['match'] as String?,
      matchScore: (json['matchScore'] as num?)?.toDouble(),
      reviewNeeded: json['reviewNeeded'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'match': match,
        'matchScore': matchScore,
        'reviewNeeded': reviewNeeded,
        'confidence': confidence,
      };
}
