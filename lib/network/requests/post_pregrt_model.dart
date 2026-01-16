class RequestPostPreGRT {
  List<String>? cGTId;
  String? userId;
  DateTime? grtDay;
  List<PreGRTMember>? gRTMembers;
  double? lat;
  double? lng;

  RequestPostPreGRT({
    this.cGTId,
    this.userId,
    this.grtDay,
    this.gRTMembers,
    this.lat,
    this.lng,
  });

  // Convert RequestPostPreGRT object to JSON
  Map<String, dynamic> toJson() {
    return {
      'cGTId': cGTId,
      'userId': userId,
      'grtDay': grtDay?.toIso8601String(), // Serialize date as ISO string
      'gRTMembers': gRTMembers?.map((member) => member.toJson()).toList(),
      'lat': lat,
      'lng': lng,
    };
  }
}

class PreGRTMember {
  String? memberCGTId;
  bool? isDropped;
  bool? isPresent;
  bool? isPassed;
  bool? bankAcCheck;
  bool? isDocOpdAvailed; // New field
  String? sanctionAmount; // New field

  PreGRTMember({
    this.memberCGTId,
    this.isDropped,
    this.isPresent,
    this.isPassed,
    this.bankAcCheck,
    this.isDocOpdAvailed, // Initialize new field
    this.sanctionAmount, // Initialize new field
  });

  // Convert PreGRTMember object to JSON
  Map<String, dynamic> toJson() {
    return {
      'memberCGTId': memberCGTId,
      'isDropped': isDropped,
      'isPresent': isPresent,
      'isPassed': isPassed,
      'bankAcCheck': bankAcCheck,
      'isDocOpdAvailed': isDocOpdAvailed, // Serialize new field
      'sanctionAmount': sanctionAmount, // Serialize new field
    };
  }
}
