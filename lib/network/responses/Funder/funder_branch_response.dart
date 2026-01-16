class FunderBranchResponse {
  final int bid;
  final String branchName;

  FunderBranchResponse({
    required this.bid,
    required this.branchName,
  });

  factory FunderBranchResponse.fromJson(Map<String, dynamic> json) {
    return FunderBranchResponse(
      bid: json['BID'] as int,
      branchName: json['BRANCHNAME'] as String,
    );
  }

  static List<FunderBranchResponse> listFromJson(List<dynamic> json) {
    return json.map((e) => FunderBranchResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'BID': bid,
      'BRANCHNAME': branchName,
    };
  }
} 