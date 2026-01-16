import 'dart:convert';

class GoldLoanResponse {
  final String? success;
  final String? message;
  final String? leadId;
  final List<GoldLoanOffer>? offers;

  GoldLoanResponse({
    this.success,
    this.message,
    this.leadId,
    this.offers,
  });

  factory GoldLoanResponse.fromJson(Map<String, dynamic> json) {
    return GoldLoanResponse(
      success: json['success']?.toString(),
      message: json['message'],
      leadId: json['leadId'],
      offers: (json['offers'] as List?)?.map((e) => GoldLoanOffer.fromJson(e)).toList(),
    );
  }
}

class GoldLoanOffer {
  final String? message;
  final int? lenderId;
  final String? lenderName;
  final String? lenderLogo;

  GoldLoanOffer({
    this.message,
    this.lenderId,
    this.lenderName,
    this.lenderLogo,
  });

  factory GoldLoanOffer.fromJson(Map<String, dynamic> json) {
    return GoldLoanOffer(
      message: json['message'],
      lenderId: json['lenderId'],
      lenderName: json['lenderName'],
      lenderLogo: json['lenderLogo'],
    );
  }
}

class HousingLoanResponse {
  final String? success;
  final String? message;
  final String? leadId;
  final List<HousingLoanOffer>? offers;

  HousingLoanResponse({
    this.success,
    this.message,
    this.leadId,
    this.offers,
  });

  factory HousingLoanResponse.fromJson(Map<String, dynamic> json) {
    return HousingLoanResponse(
      success: json['success']?.toString(),
      message: json['message'],
      leadId: json['leadId'],
      offers: (json['offers'] as List?)?.map((e) => HousingLoanOffer.fromJson(e)).toList(),
    );
  }
}

class HousingLoanOffer {
  final int? lenderId;
  final String? lenderName;
  final String? lenderLogo;
  final String? offerLink;

  HousingLoanOffer({
    this.lenderId,
    this.lenderName,
    this.lenderLogo,
    this.offerLink,
  });

  factory HousingLoanOffer.fromJson(Map<String, dynamic> json) {
    return HousingLoanOffer(
      lenderId: json['lenderId'],
      lenderName: json['lenderName'],
      lenderLogo: json['lenderLogo'],
      offerLink: json['offerLink'],
    );
  }
} 