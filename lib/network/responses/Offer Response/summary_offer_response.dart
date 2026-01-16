class SummaryOfferResponse {
  final String success;
  final Summary summary;
  final String redirectionUrl;

  SummaryOfferResponse({
    required this.success,
    required this.summary,
    required this.redirectionUrl,
  });

  factory SummaryOfferResponse.fromJson(Map<String, dynamic> json) {
    return SummaryOfferResponse(
      success: json['success'] as String,
      summary: Summary.fromJson(json['summary']),
      redirectionUrl: json['redirectionUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'summary': summary.toJson(),
      'redirectionUrl': redirectionUrl,
    };
  }
}

class Summary {
  final int offersTotal;
  final String maxLoanAmount;
  final int minMPR;
  final int maxMPR;

  Summary({
    required this.offersTotal,
    required this.maxLoanAmount,
    required this.minMPR,
    required this.maxMPR,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      offersTotal: json['offersTotal'] as int,
      maxLoanAmount: json['maxLoanAmount'] as String,
      minMPR: json['minMPR'] as int,
      maxMPR: json['maxMPR'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offersTotal': offersTotal,
      'maxLoanAmount': maxLoanAmount,
      'minMPR': minMPR,
      'maxMPR': maxMPR,
    };
  }
}
