
class OCRResponseModel {
  final String? requestId;
  final Result? result;
  final int? statusCode;
  final String? statusMessage;

  OCRResponseModel({
    this.requestId,
    this.result,
    this.statusCode,
    this.statusMessage,
  });

  factory OCRResponseModel.fromJson(Map<String, dynamic> json) => OCRResponseModel(
        requestId: json['requestId'] as String?,
        result: json['result'] != null
            ? Result.fromJson(json['result'] as Map<String, dynamic>)
            : null,
        statusCode: json['statusCode'] as int?,
        statusMessage: json['statusMessage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'result': result?.toJson(),
        'statusCode': statusCode,
        'statusMessage': statusMessage,
      };
}


class Result {
  final List<Document>? documents;

  Result({this.documents});

  factory Result.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return Result(documents: []); // Handle empty result gracefully
    }
    return Result(
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'documents': documents?.map((e) => e.toJson()).toList(),
      };
}


class Document {
  final String? documentType;
  final String? subType;
  final int? pageNo;
  final OcrData? ocrData;
  final AdditionalDetails? additionalDetails;

  Document({
    this.documentType,
    this.subType,
    this.pageNo,
    this.ocrData,
    this.additionalDetails,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        documentType: json['documentType'] as String?,
        subType: json['subType'] as String?,
        pageNo: json['pageNo'] as int?,
        ocrData: json['ocrData'] != null
            ? OcrData.fromJson(json['ocrData'] as Map<String, dynamic>)
            : null,
        additionalDetails: json['additionalDetails'] != null
            ? AdditionalDetails.fromJson(json['additionalDetails'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'subType': subType,
        'pageNo': pageNo,
        'ocrData': ocrData?.toJson(),
        'additionalDetails': additionalDetails?.toJson(),
      };
}

class OcrData {
  final Map<String, OcrValue>? fields;

  OcrData({this.fields});

  factory OcrData.fromJson(Map<String, dynamic> json) {
    final fields = json.map((key, value) => MapEntry(key, OcrValue.fromJson(value)));
    return OcrData(fields: fields);
  }

  Map<String, dynamic> toJson() => fields?.map((key, value) => MapEntry(key, value.toJson())) ?? {};
}

class OcrValue {
  final String? value;

  OcrValue({this.value});

  factory OcrValue.fromJson(Map<String, dynamic> json) => OcrValue(
        value: json['value'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
      };
}

class AdditionalDetails {
  final InputMaskStatus? inputMaskStatus;
  final bool? verhoeffCheck;
  final bool? outputMaskStatus;
  final String? qr;
  final String? barcode;
  final AddressSplit? addressSplit;
  final CareOfDetails? careOfDetails;

  AdditionalDetails({
    this.inputMaskStatus,
    this.verhoeffCheck,
    this.outputMaskStatus,
    this.qr,
    this.barcode,
    this.addressSplit,
    this.careOfDetails,
  });

  factory AdditionalDetails.fromJson(Map<String, dynamic> json) => AdditionalDetails(
        inputMaskStatus: json['inputMaskStatus'] != null
            ? InputMaskStatus.fromJson(json['inputMaskStatus'] as Map<String, dynamic>)
            : null,
        verhoeffCheck: json['verhoeffCheck'] as bool?,
        outputMaskStatus: json['outputMaskStatus'] as bool?,
        qr: json['qr'] as String?,
        barcode: json['barcode'] as String?,
        addressSplit: json['addressSplit'] != null
            ? AddressSplit.fromJson(json['addressSplit'] as Map<String, dynamic>)
            : null,
        careOfDetails: json['careOfDetails'] != null
            ? CareOfDetails.fromJson(json['careOfDetails'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'inputMaskStatus': inputMaskStatus?.toJson(),
        'verhoeffCheck': verhoeffCheck,
        'outputMaskStatus': outputMaskStatus,
        'qr': qr,
        'barcode': barcode,
        'addressSplit': addressSplit?.toJson(),
        'careOfDetails': careOfDetails?.toJson(),
      };
}

class InputMaskStatus {
  final bool? isMasked;
  final String? maskedBy;
  final double? confidence;

  InputMaskStatus({
    this.isMasked,
    this.maskedBy,
    this.confidence,
  });

  factory InputMaskStatus.fromJson(Map<String, dynamic> json) => InputMaskStatus(
        isMasked: json['isMasked'] as bool?,
        maskedBy: json['maskedBy'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'isMasked': isMasked,
        'maskedBy': maskedBy,
        'confidence': confidence,
      };
}

class AddressSplit {
  final String? building;
  final String? city;
  final String? district;
  final String? pin;
  final String? floor;
  final String? house;
  final String? locality;
  final String? state;
  final String? street;
  final String? complex;
  final String? landmark;
  final String? untagged;

  AddressSplit({
    this.building,
    this.city,
    this.district,
    this.pin,
    this.floor,
    this.house,
    this.locality,
    this.state,
    this.street,
    this.complex,
    this.landmark,
    this.untagged,
  });

  factory AddressSplit.fromJson(Map<String, dynamic> json) => AddressSplit(
        building: json['building'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        pin: json['pin'] as String?,
        floor: json['floor'] as String?,
        house: json['house'] as String?,
        locality: json['locality'] as String?,
        state: json['state'] as String?,
        street: json['street'] as String?,
        complex: json['complex'] as String?,
        landmark: json['landmark'] as String?,
        untagged: json['untagged'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'building': building,
        'city': city,
        'district': district,
        'pin': pin,
        'floor': floor,
        'house': house,
        'locality': locality,
        'state': state,
        'street': street,
        'complex': complex,
        'landmark': landmark,
        'untagged': untagged,
      };
}

class CareOfDetails {
  final String? relation;
  final String? name;

  CareOfDetails({this.relation, this.name});

  factory CareOfDetails.fromJson(Map<String, dynamic> json) => CareOfDetails(
        relation: json['relation'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'relation': relation,
        'name': name,
      };
}
