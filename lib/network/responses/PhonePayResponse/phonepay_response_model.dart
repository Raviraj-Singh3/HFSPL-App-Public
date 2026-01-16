
class PhonePeResponse {
  final String? code;
  final Data? data;
  final String? message;
  final bool? success;

  PhonePeResponse({
    this.code,
    this.data,
    this.message,
    this.success,
  });

  factory PhonePeResponse.fromJson(Map<String, dynamic> json) {
    return PhonePeResponse(
      code: json['code'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data?.toJson(),
      'message': message,
      'success': success,
    };
  }
}

class Data {
  final int? amount;
  final String? merchantId;
  final String? payResponseCode;
  final String? paymentState;
  final String? providerReferenceId;
  final String? qrString;
  final String? upiIntent;
  final String? payLink;
  final String? mobileNumber;
  final String? transactionId;

  Data({
    this.amount,
    this.merchantId,
    this.payResponseCode,
    this.paymentState,
    this.providerReferenceId,
    this.qrString,
    this.upiIntent,
    this.payLink,
    this.mobileNumber,
    this.transactionId,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      amount: json['amount'],
      merchantId: json['merchantId'],
      payResponseCode: json['payResponseCode'],
      paymentState: json['paymentState'],
      providerReferenceId: json['providerReferenceId'],
      qrString: json['qrString'],
      upiIntent: json['upiIntent'],
      payLink: json['payLink'],
      mobileNumber: json['mobileNumber'],
      transactionId: json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'merchantId': merchantId,
      'payResponseCode': payResponseCode,
      'paymentState': paymentState,
      'providerReferenceId': providerReferenceId,
      'qrString': qrString,
      'upiIntent': upiIntent,
      'payLink': payLink,
      'mobileNumber': mobileNumber,
      'transactionId': transactionId,
    };
  }
}

// Example Usage:
// Convert JSON to Model
// final model = PhonePeResponse.fromJson(jsonDecode(jsonString));

// Convert Model to JSON
// final jsonString = jsonEncode(model.toJson());
