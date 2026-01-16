class DropdownModel {
  int? iD;
  String? village;

  DropdownModel({this.iD, this.village});

  DropdownModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    village = json['Village'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ID'] = iD;
    data['Village'] = village;
    return data;
  }
}
