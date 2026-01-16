class AadharModel {
  final String? requestId;
  final Result? result;
  final int? statusCode;
  final String? statusMessage;
  final ClientData? clientData;

  AadharModel({
    this.requestId,
    this.result,
    this.statusCode,
    this.statusMessage,
    this.clientData,
  });

  // JSON Parsing
  factory AadharModel.fromJson(Map<String, dynamic> json) => AadharModel(
        requestId: json['requestId'] as String?,
        result: json['result'] != null && (json['result'] as Map).isNotEmpty
            ? Result.fromJson(json['result'] as Map<String, dynamic>)
            : null,
        statusCode: json['statusCode'] as int?,
        statusMessage: json['statusMessage'] as String?,
        clientData: json['clientData'] != null
            ? ClientData.fromJson(json['clientData'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'result': result?.toJson(),
        'statusCode': statusCode,
        'statusMessage': statusMessage,
        'clientData': clientData?.toJson(),
      };
}

class Result {
  final DataFromAadhaar? dataFromAadhaar;

  Result({this.dataFromAadhaar});

  // JSON Parsing
  factory Result.fromJson(Map<String, dynamic> json) => Result(
        dataFromAadhaar: json['dataFromAadhaar'] != null
            ? DataFromAadhaar.fromJson(json['dataFromAadhaar'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'dataFromAadhaar': dataFromAadhaar?.toJson(),
      };
}

class ClientData {
  final String? caseId;

  ClientData({this.caseId});

  // JSON Parsing
  factory ClientData.fromJson(Map<String, dynamic> json) => ClientData(
        caseId: json['caseId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
      };
}

class DataFromAadhaar {
  final String? generatedDateTime;
  final String? maskedAadhaarNumber;
  final String? name;
  final String? dob;
  final String? gender;
  final String? mobileHash;
  final String? emailHash;
  final String? fatherName;
  final Address? address;
  final String? image;

  DataFromAadhaar({
    this.generatedDateTime,
    this.maskedAadhaarNumber,
    this.name,
    this.dob,
    this.gender,
    this.mobileHash,
    this.emailHash,
    this.fatherName,
    this.address,
    this.image,
  });

  factory DataFromAadhaar.fromJson(Map<String, dynamic> json) => DataFromAadhaar(
        generatedDateTime: json['generatedDateTime'] as String?,
        maskedAadhaarNumber: json['maskedAadhaarNumber'] as String?,
        name: json['name'] as String?,
        dob: json['dob'] as String?,
        gender: json['gender'] as String?,
        mobileHash: json['mobileHash'] as String?,
        emailHash: json['emailHash'] as String?,
        fatherName: json['fatherName'] as String?,
        address: json['address'] != null
            ? Address.fromJson(json['address'] as Map<String, dynamic>)
            : null,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'generatedDateTime': generatedDateTime,
        'maskedAadhaarNumber': maskedAadhaarNumber,
        'name': name,
        'dob': dob,
        'gender': gender,
        'mobileHash': mobileHash,
        'emailHash': emailHash,
        'fatherName': fatherName,
        'address': address?.toJson(),
        'image': image,
      };
}

class Address {
  final SplitAddress? splitAddress;
  final String? combinedAddress;

  Address({this.splitAddress, this.combinedAddress});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        splitAddress: json['splitAddress'] != null
            ? SplitAddress.fromJson(json['splitAddress'] as Map<String, dynamic>)
            : null,
        combinedAddress: json['combinedAddress'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'splitAddress': splitAddress?.toJson(),
        'combinedAddress': combinedAddress,
      };
}

class SplitAddress {
  final String? houseNumber;
  final String? street;
  final String? landmark;
  final String? subdistrict;
  final String? district;
  final String? vtcName;
  final String? location;
  final String? postOffice;
  final String? state;
  final String? country;
  final String? pincode;

  SplitAddress({
    this.houseNumber,
    this.street,
    this.landmark,
    this.subdistrict,
    this.district,
    this.vtcName,
    this.location,
    this.postOffice,
    this.state,
    this.country,
    this.pincode,
  });

  factory SplitAddress.fromJson(Map<String, dynamic> json) => SplitAddress(
        houseNumber: json['houseNumber'] as String?,
        street: json['street'] as String?,
        landmark: json['landmark'] as String?,
        subdistrict: json['subdistrict'] as String?,
        district: json['district'] as String?,
        vtcName: json['vtcName'] as String?,
        location: json['location'] as String?,
        postOffice: json['postOffice'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        pincode: json['pincode'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'houseNumber': houseNumber,
        'street': street,
        'landmark': landmark,
        'subdistrict': subdistrict,
        'district': district,
        'vtcName': vtcName,
        'location': location,
        'postOffice': postOffice,
        'state': state,
        'country': country,
        'pincode': pincode,
      };
}
