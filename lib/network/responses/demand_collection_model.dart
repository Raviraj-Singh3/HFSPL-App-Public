class DemandCollectionModel {
  final int? totalNumberOfDemand;
  final double? totalSumOfDemand;
  final int? totalNumberOfCollection;
  final double? totalSumOfCollection;
  final double? totalOverdueDemandAmount;
  final int? totalOverdueDemandClients;
  final List<BranchData>? branchWiseData;

  DemandCollectionModel({
    this.totalNumberOfDemand,
    this.totalSumOfDemand,
    this.totalNumberOfCollection,
    this.totalSumOfCollection,
    this.totalOverdueDemandAmount,
    this.totalOverdueDemandClients,
    this.branchWiseData,
  });

  factory DemandCollectionModel.fromJson(Map<String, dynamic> json) {
    return DemandCollectionModel(
      totalNumberOfDemand: json['TotalNumberOfDemand'] as int?,
      totalSumOfDemand: (json['TotalSumOfDemand'] as num?)?.toDouble(),
      totalNumberOfCollection: json['TotalNumberOfCollection'] as int?,
      totalSumOfCollection: (json['TotalSumOfCollection'] as num?)?.toDouble(),
      totalOverdueDemandAmount: (json['TotalOverdueDemandAmount'] as num?)?.toDouble(),
      totalOverdueDemandClients: json['TotalOverdueDemandClients'] as int?,
      branchWiseData: (json['BranchWiseData'] as List?)
          ?.map((e) => BranchData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "TotalNumberOfDemand": totalNumberOfDemand,
      "TotalSumOfDemand": totalSumOfDemand,
      "TotalNumberOfCollection": totalNumberOfCollection,
      "TotalSumOfCollection": totalSumOfCollection,
      "TotalOverdueDemandAmount": totalOverdueDemandAmount,
      "TotalOverdueDemandClients": totalOverdueDemandClients,
      "BranchWiseData": branchWiseData?.map((e) => e.toJson()).toList(),
    };
  }
}

class BranchData {
  final int? branchID;
  final String? branchName;
  final int? numberOfDemand;
  final double? sumOfDemand;
  final int? numberOfCollection;
  final double? sumOfCollection;
  final double? overdueDemandAmount;
  final int? overdueDemandClients;

  BranchData({
    this.branchID,
    this.branchName,
    this.numberOfDemand,
    this.sumOfDemand,
    this.numberOfCollection,
    this.sumOfCollection,
    this.overdueDemandAmount,
    this.overdueDemandClients,
  });

  factory BranchData.fromJson(Map<String, dynamic> json) {
    return BranchData(
      branchID: json['BranchID'] as int?,
      branchName: json['BranchName'] as String?,
      numberOfDemand: json['NumberOfDemand'] as int?,
      sumOfDemand: (json['SumOfDemand'] as num?)?.toDouble(),
      numberOfCollection: json['NumberOfCollection'] as int?,
      sumOfCollection: (json['SumOfCollection'] as num?)?.toDouble(),
      overdueDemandAmount: (json['OverdueDemandAmount'] as num?)?.toDouble(),
      overdueDemandClients: json['OverdueDemandClients'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "BranchID": branchID,
      "BranchName": branchName,
      "NumberOfDemand": numberOfDemand,
      "SumOfDemand": sumOfDemand,
      "NumberOfCollection": numberOfCollection,
      "SumOfCollection": sumOfCollection,
      "OverdueDemandAmount": overdueDemandAmount,
      "OverdueDemandClients": overdueDemandClients,
    };
  }
}
