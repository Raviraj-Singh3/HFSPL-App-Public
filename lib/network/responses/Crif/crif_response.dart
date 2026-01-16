class CrifResponseModel {
  final List<ReportRow>? reportRows;
  final List<FinalDecisionRow>? finalDecisionRows;
  final List<MemberIndReportPath>? memberIndReportPaths;
  final bool isSuccess;
  final String message;

  CrifResponseModel({
    this.reportRows,
    this.finalDecisionRows,
    this.memberIndReportPaths,
    required this.isSuccess,
    required this.message,
  });

  // Manual JSON Parsing
  factory CrifResponseModel.fromJson(Map<String, dynamic> json) {
    return CrifResponseModel(
      reportRows: (json['ReportRows'] as List<dynamic>?)
          ?.map((e) => ReportRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      finalDecisionRows: (json['FinalDecisionRows'] as List<dynamic>?)
          ?.map((e) => FinalDecisionRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberIndReportPaths: (json['MemberIndReportPaths'] as List<dynamic>?)
          ?.map((e) => MemberIndReportPath.fromJson(e as Map<String, dynamic>))
          .toList(),
      isSuccess: json['IsSuccess'] as bool,
      message: json['Message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'ReportRows': reportRows?.map((e) => e.toJson()).toList(),
        'FinalDecisionRows': finalDecisionRows?.map((e) => e.toJson()).toList(),
        'MemberIndReportPaths':
            memberIndReportPaths?.map((e) => e.toJson()).toList(),
        'IsSuccess': isSuccess,
        'Message': message,
      };
}

class ReportRow {
  // Placeholder class for future fields
  ReportRow();

  factory ReportRow.fromJson(Map<String, dynamic> json) {
    return ReportRow();
  }

  Map<String, dynamic> toJson() => {};
}

class FinalDecisionRow {
  final double? totalOD;
  final double? totalWO;
  final double? totalInstallment;
  final double? totalOutStanding;
  final double? monthlyEligibleAmt;
  final double? eligibleProduct;
  final int? eligibleProductEMI;
  final String? status;

  FinalDecisionRow({
    this.totalOD,
    this.totalWO,
    this.totalInstallment,
    this.totalOutStanding,
    this.monthlyEligibleAmt,
    this.eligibleProduct,
    this.eligibleProductEMI,
    this.status,
  });

  // Manual JSON Parsing
  factory FinalDecisionRow.fromJson(Map<String, dynamic> json) {
    return FinalDecisionRow(
      totalOD: (json['totalOD'] as num?)?.toDouble(),
      totalWO: (json['totalWO'] as num?)?.toDouble(),
      totalInstallment: (json['totalInstallment'] as num?)?.toDouble(),
      totalOutStanding: (json['totalOutStanding'] as num?)?.toDouble(),
      monthlyEligibleAmt: (json['MonthlyEligibleAmt'] as num?)?.toDouble(),
      eligibleProduct: (json['EligibleProduct'] as num?)?.toDouble(),
      eligibleProductEMI: json['EligibleProductEMI'] as int?,
      status: json['Status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalOD': totalOD,
        'totalWO': totalWO,
        'totalInstallment': totalInstallment,
        'totalOutStanding': totalOutStanding,
        'MonthlyEligibleAmt': monthlyEligibleAmt,
        'EligibleProduct': eligibleProduct,
        'EligibleProductEMI': eligibleProductEMI,
        'Status': status,
      };
}

class MemberIndReportPath {
  final String? item1;
  final String? item2;

  MemberIndReportPath({
    this.item1,
    this.item2,
  });

  // Manual JSON Parsing
  factory MemberIndReportPath.fromJson(Map<String, dynamic> json) {
    return MemberIndReportPath(
      item1: json['Item1'] as String?,
      item2: json['Item2'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Item1': item1,
        'Item2': item2,
      };
}
