class ReportingPersonModel {
  final int id;
  final String name;
  final String branch;
  final String designation;

  ReportingPersonModel({
    required this.id,
    required this.name,
    required this.branch,
    required this.designation,
  });

  factory ReportingPersonModel.fromJson(Map<String, dynamic> json) {
    return ReportingPersonModel(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
      branch: json['Branch'] ?? '',
      designation: json['Designation'] ?? '',
    );
  }

  static List<ReportingPersonModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => ReportingPersonModel.fromJson(e)).toList();
  }
}
