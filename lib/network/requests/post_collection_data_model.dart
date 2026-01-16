class PostCollectionDataModel {
  int? mId;
  int? vId;
  double? amount;
  DateTime? transactionDate;
  double? lat;
  double? lng;
  int? postedBy;
  bool? isPresent;

  PostCollectionDataModel({
    this.mId,
    this.vId,
    this.amount,
    this.transactionDate,
    this.lat,
    this.lng,
    this.postedBy,
    this.isPresent,
  });

  // Convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'm_id': mId,
      'v_id': vId,
      'amount': amount,
      'transactionDate': transactionDate?.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'postedBy': postedBy,
      'isPresent': isPresent,
    };
  }

  // Convert a list of models to JSON
  static List<Map<String, dynamic>> listToJson(List<PostCollectionDataModel> models) {
    return models.map((model) => model.toJson()).toList();
  }
}
