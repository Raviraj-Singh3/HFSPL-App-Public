class OfferResponseModel {
  final String success;
  final List<OfferModel> offers;

  OfferResponseModel({
    required this.success,
    required this.offers,
  });

  factory OfferResponseModel.fromJson(Map<String, dynamic> json) {
    return OfferResponseModel(
      success: json['success'] as String,
      offers: (json['offers'] as List)
          .map((e) => OfferModel.fromJson(e))
          .toList(),
    );
  }
}
class OfferModel {
  final int lenderId;
  final String lenderName;
  final String lenderLogo;
  final String offerAmountUpTo;
  final String offerTenure;
  final String offerInterestRate;
  final String offerProcessingFees;
  final String status;
  final String offerLink;

  OfferModel({
    required this.lenderId,
    required this.lenderName,
    required this.lenderLogo,
    required this.offerAmountUpTo,
    required this.offerTenure,
    required this.offerInterestRate,
    required this.offerProcessingFees,
    required this.status,
    required this.offerLink,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      lenderId: json['lenderId'],
      lenderName: json['lenderName'],
      lenderLogo: json['lenderLogo'],
      offerAmountUpTo: json['offerAmountUpTo'],
      offerTenure: json['offerTenure'],
      offerInterestRate: json['offerInterestRate'],
      offerProcessingFees: json['offerProcessingFees'],
      status: json['status'],
      offerLink: json['offerLink'],
    );
  }
}
