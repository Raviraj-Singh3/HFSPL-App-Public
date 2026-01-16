class FunderDetailsResponse {
  final bool isMaster;
  final List<int> branchIds;
  final List<Funder> funders;

  FunderDetailsResponse({
    required this.isMaster,
    required this.branchIds,
    required this.funders,
  });

  factory FunderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return FunderDetailsResponse(
      isMaster: json['IsMaster'] as bool,
      branchIds: (json['BranchIds'] as List<dynamic>).map((e) => e as int).toList(),
      funders: (json['Funders'] as List<dynamic>)
          .map((e) => Funder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Funder {
  final int funderId;
  final String funderName;
  final List<FunderBranch> branches;

  Funder({
    required this.funderId,
    required this.funderName,
    required this.branches,
  });

  factory Funder.fromJson(Map<String, dynamic> json) {
    return Funder(
      funderId: json['FunderId'] as int,
      funderName: json['FunderName'] as String,
      branches: (json['Branches'] as List<dynamic>)
          .map((e) => FunderBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FunderBranch {
  final int branchId;
  final String branchName;

  FunderBranch({
    required this.branchId,
    required this.branchName,
  });

  factory FunderBranch.fromJson(Map<String, dynamic> json) {
    return FunderBranch(
      branchId: json['BranchId'] as int,
      branchName: json['BranchName'] as String,
    );
  }
} 