class FeWiseDemandCollectionModel {
  final List<FeData>? feWiseData;

  FeWiseDemandCollectionModel({this.feWiseData});

  factory FeWiseDemandCollectionModel.fromJson(Map<String, dynamic> json) {
    return FeWiseDemandCollectionModel(
      feWiseData: (json['FEWiseData'] as List?)
          ?.map((e) => FeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "FEWiseData": feWiseData?.map((e) => e.toJson()).toList(),
    };
  }
}

class FeData {
  final int? feId;
  final String? feName;
  final int? branchId;
  final String? branchName;
  final int? numberOfDemand;
  final double? sumOfDemand;
  final int? numberOfCollection;
  final double? sumOfCollection;
  final int? totalActiveClients;
  final double? overdueDemandAmount;
  final int? overdueDemandClients;

  FeData({
    this.feId,
    this.feName,
    this.branchId,
    this.branchName,
    this.numberOfDemand,
    this.sumOfDemand,
    this.numberOfCollection,
    this.sumOfCollection,
    this.totalActiveClients,
    this.overdueDemandAmount,
    this.overdueDemandClients,
  });

  factory FeData.fromJson(Map<String, dynamic> json) {
    return FeData(
      feId: json['FEID'] as int?,
      feName: json['FEName'] as String?,
      branchId: json['BranchID'] as int?,
      branchName: json['BranchName'] as String?,
      numberOfDemand: json['NumberOfDemand'] as int?,
      sumOfDemand: (json['SumOfDemand'] as num?)?.toDouble(),
      numberOfCollection: json['NumberOfCollection'] as int?,
      sumOfCollection: (json['SumOfCollection'] as num?)?.toDouble(),
      totalActiveClients: json['TotalActiveClients'] as int?,
      overdueDemandAmount: (json['OverdueDemandAmount'] as num?)?.toDouble(),
      overdueDemandClients: json['OverdueDemandClients'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "FEID": feId,
      "FEName": feName,
      "BranchID": branchId,
      "BranchName": branchName,
      "NumberOfDemand": numberOfDemand,
      "SumOfDemand": sumOfDemand,
      "NumberOfCollection": numberOfCollection,
      "SumOfCollection": sumOfCollection,
      "TotalActiveClients": totalActiveClients,
      "OverdueDemandAmount": overdueDemandAmount,
      "OverdueDemandClients": overdueDemandClients,
    };
  }
}
