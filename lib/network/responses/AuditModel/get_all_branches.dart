class BranchModel {
  final int? bid;
  final String? branchName;

  BranchModel({
    this.bid,
    this.branchName,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      bid: json['BID'] as int?,
      branchName: json['BRANCHNAME'] as String?,
    );
  }

  /// Method to convert the model instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'BID': bid,
      'BRANCHNAME': branchName,
    };
  }

  /// Static method to convert a JSON array into a list of model instances.
  static List<BranchModel> listFromJson(List<dynamic> jsonData) {
    return jsonData
        .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
