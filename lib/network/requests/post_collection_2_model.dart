class CollectionPostRequest {
  bool asPerSchedule;
  List<CollectionPostMember> members;

  CollectionPostRequest({
    required this.asPerSchedule,
    required this.members,
  });

  Map<String, dynamic> toJson() {
    return {
      "AsPerSchedule": asPerSchedule,
      "Members": members.map((m) => m.toJson()).toList(),
    };
  }
}

class CollectionPostMember {
  int memberId;
  double postedAmount;
  bool isPresent;
  bool isOD;
  bool isSelected;
  String memberName;
  double lat;
  double lng;
  int postedBy;

  CollectionPostMember({
    required this.memberId,
    required this.postedAmount,
    required this.isPresent,
    required this.isOD,
    required this.isSelected,
    required this.memberName,
    required this.lat,
    required this.lng,
    required this.postedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      "MemberId": memberId,
      "PostedAmount": postedAmount,
      "IsPresent": isPresent,
      "IsOD": isOD,
      "IsSelected": isSelected,
      "MemberName": memberName,
      "Lat": lat,
      "Lng": lng,
      "PostedBy": postedBy,
    };
  }
}