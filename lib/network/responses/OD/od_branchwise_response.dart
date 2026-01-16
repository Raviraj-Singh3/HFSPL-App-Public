class ODBranchWiseResponse {
  final int regionId;
  final String regionName;
  final List<ODArea> areas;
  final int totalNewOds;
  final int totalClosedOds;

  ODBranchWiseResponse({
    required this.regionId,
    required this.regionName,
    required this.areas,
    required this.totalNewOds,
    required this.totalClosedOds,
  });

  factory ODBranchWiseResponse.fromJson(Map<String, dynamic> json) {
    return ODBranchWiseResponse(
      regionId: json['RegionId'],
      regionName: json['RegionName'],
      areas: (json['Areas'] as List)
          .map((e) => ODArea.fromJson(e))
          .toList(),
      totalNewOds: json['TotalNewOds'],
      totalClosedOds: json['TotalClosedOds'],
    );
  }

  static List<ODBranchWiseResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => ODBranchWiseResponse.fromJson(e)).toList();
  }
}


class ODArea {
  final int areaId;
  final String areaName;
  final List<ODBranch> branches;
  final int totalNewOds;
  final int totalClosedOds;

  ODArea({
    required this.areaId,
    required this.areaName,
    required this.branches,
    required this.totalNewOds,
    required this.totalClosedOds,
  });

  factory ODArea.fromJson(Map<String, dynamic> json) {
    return ODArea(
      areaId: json['AreaId'],
      areaName: json['AreaName'],
      branches: (json['Branches'] as List)
          .map((e) => ODBranch.fromJson(e))
          .toList(),
      totalNewOds: json['TotalNewOds'],
      totalClosedOds: json['TotalClosedOds'],
    );
  }
}

class ODBranch {
  final int funderId;
  final String funderName;
  final int branchId;
  final String branchName;
  final double totalAmtPayableOneDayBack;
  final double totalOsOneDayBack;
  final int totalMembersOneDayBack;
  final int totalNewOds;
  final int totalClosedOds;
  final double totalAmtPayableTwoDaysBack;
  final double totalOsTwoDaysBack;
  final int totalMembersTwoDaysBack;

  ODBranch({
    required this.funderId,
    required this.funderName,
    required this.branchId,
    required this.branchName,
    required this.totalAmtPayableOneDayBack,
    required this.totalOsOneDayBack,
    required this.totalMembersOneDayBack,
    required this.totalNewOds,
    required this.totalClosedOds,
    required this.totalAmtPayableTwoDaysBack,
    required this.totalOsTwoDaysBack,
    required this.totalMembersTwoDaysBack,
  });

  factory ODBranch.fromJson(Map<String, dynamic> json) {
    return ODBranch(
      funderId: json['FunderId'],
      funderName: json['FunderName'],
      branchId: json['BranchId'],
      branchName: json['BranchName'],
      totalAmtPayableOneDayBack: json['TotalAmtPayableOneDayBack'],
      totalOsOneDayBack: json['TotalOsOneDayBack'],
      totalMembersOneDayBack: json['TotalMembersOneDayBack'],
      totalNewOds: json['TotalNewOds'],
      totalClosedOds: json['TotalClosedOds'],
      totalAmtPayableTwoDaysBack: json['TotalAmtPayableTwoDaysBack'],
      totalOsTwoDaysBack: json['TotalOsTwoDaysBack'],
      totalMembersTwoDaysBack: json['TotalMembersTwoDaysBack'],
    );
  }
}