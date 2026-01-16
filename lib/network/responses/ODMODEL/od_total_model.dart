class OdTotalModel {
  final double? totalAmtPaybleOneDayBack;
  final double? totalOSOneDayBack;
  final double? totalAmtPaybleTwoDaysBack;
  final double? totalOSTwoDaysBack;
  final int? totalMembersOneDayBack;
  final int? totalMembersTwoDaysBack;
  final int? totalNewODs;
  final int? totalClosedODs;

  OdTotalModel({
    this.totalAmtPaybleOneDayBack,
    this.totalOSOneDayBack,
    this.totalAmtPaybleTwoDaysBack,
    this.totalOSTwoDaysBack,
    this.totalMembersOneDayBack,
    this.totalMembersTwoDaysBack,
    this.totalNewODs,
    this.totalClosedODs
  });

  factory OdTotalModel.fromJson(Map<String, dynamic> json) {
    return OdTotalModel(
      totalAmtPaybleOneDayBack: (json['TotalAmtPaybleOneDayBack'] as num?)?.toDouble(),
      totalOSOneDayBack: (json['TotalOSOneDayBack'] as num?)?.toDouble(),
      totalAmtPaybleTwoDaysBack: (json['TotalAmtPaybleTwoDaysBack'] as num?)?.toDouble(),
      totalOSTwoDaysBack: (json['TotalOSTwoDaysBack'] as num?)?.toDouble(),
      totalMembersOneDayBack: json['TotalMembersOneDayBack'] as int?,
      totalMembersTwoDaysBack: json['TotalMembersTwoDaysBack'] as int?,
      totalNewODs: json['TotalNewODs'] as int?,
      totalClosedODs: json['TotalClosedODs'] as int?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "TotalAmtPaybleOneDayBack": totalAmtPaybleOneDayBack,
      "TotalOSOneDayBack": totalOSOneDayBack,
      "TotalAmtPaybleTwoDaysBack": totalAmtPaybleTwoDaysBack,
      "TotalOSTwoDaysBack": totalOSTwoDaysBack,
      "TotalMembersOneDayBack": totalMembersOneDayBack,
      "TotalMembersTwoDaysBack": totalMembersTwoDaysBack,
      "TotalNewODs": totalNewODs,
      "TotalClosedODs": totalClosedODs,
    };
  }
}
