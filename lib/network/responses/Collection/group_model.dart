
class Group {
  int? id;
  String? name;

  Group({
    this.id,
    this.name,
  });

  // Factory method to create a Group object from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['Id'],
      name: json['Name'],
    );
  }

  // Method to convert a Group object into JSON format
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
    };
  }

  // Method to convert a list of JSON objects into a list of Group objects
  static List<Group> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Group.fromJson(json)).toList();
  }
}
