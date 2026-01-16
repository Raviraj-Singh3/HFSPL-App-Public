class AssignDDERequest {
  List<int>? snapshotIds;
  String? ddeDate;
  int? feId;

  AssignDDERequest({
    this.snapshotIds,
    this.ddeDate,
    this.feId,
  });

  Map<String, dynamic> toJson() {
    return {
      'snapshotIds': snapshotIds,
      'ddeDate': ddeDate,
      'feId': feId,
    };
  }
}

class PostDDERequest {
  int? ddeScheduleId;
  int? clientId;
  String? clientName;
  String? ddeDateDone;
  double? latitude;
  double? longitude;
  String? notes;
  // Additional NMFI fields
  String? bankName;
  String? bankBranchName;
  String? bankIfscCode;
  String? bankAccNo;
  String? loanPurpose;
  double? loanAmount;
  String? bankStatementFile;
  String? reference1Name;
  String? reference1Mobile;
  String? reference2Name;
  String? reference2Mobile;
  String? nameInBank;

  PostDDERequest({
    this.ddeScheduleId,
    this.clientId,
    this.clientName,
    this.ddeDateDone,
    this.latitude,
    this.longitude,
    this.notes,
    this.bankName,
    this.bankBranchName,
    this.bankIfscCode,
    this.bankAccNo,
    this.loanPurpose,
    this.loanAmount,
    this.bankStatementFile,
    this.reference1Name,
    this.reference1Mobile,
    this.reference2Name,
    this.reference2Mobile,
    this.nameInBank,
  });

  Map<String, dynamic> toJson() {
    return {
      'ddeScheduleId': ddeScheduleId,
      'clientId': clientId,
      'clientName': clientName,
      'ddeDateDone': ddeDateDone,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'bankName': bankName,
      'bankBranchName': bankBranchName,
      'bankIfscCode': bankIfscCode,
      'bankAccNo': bankAccNo,
      'loanPurpose': loanPurpose,
      'loanAmount': loanAmount,
      'bankStatementFile': bankStatementFile,
      'reference1Name': reference1Name,
      'reference1Mobile': reference1Mobile,
      'reference2Name': reference2Name,
      'reference2Mobile': reference2Mobile,
      'nameInBank': nameInBank,
    };
  }
}

class AssignVerificationRequest {
  List<int>? ddeScheduleIds;
  String? verificationDate;
  int? bmUserId;

  AssignVerificationRequest({
    this.ddeScheduleIds,
    this.verificationDate,
    this.bmUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ddeScheduleIds': ddeScheduleIds,
      'verificationDate': verificationDate,
      'bmUserId': bmUserId,
    };
  }
}

class PostVerificationRequest {
  int? ddeScheduleId;
  String? verificationDateDone;
  double? latitude;
  double? longitude;
  bool? verificationPass;
  String? notes;
  // BM verification extras
  double? sanctionAmount;
  bool? bankVerified;
  bool? documentsVerified;
  bool? referencesVerified;
  String? riskFlags;
  String? bmRemarks;
  String? nameInBank;

  PostVerificationRequest({
    this.ddeScheduleId,
    this.verificationDateDone,
    this.latitude,
    this.longitude,
    this.verificationPass,
    this.notes,
    this.sanctionAmount,
    this.bankVerified,
    this.documentsVerified,
    this.referencesVerified,
    this.riskFlags,
    this.bmRemarks,
    this.nameInBank,
  });

  Map<String, dynamic> toJson() {
    return {
      'ddeScheduleId': ddeScheduleId,
      'verificationDateDone': verificationDateDone,
      'latitude': latitude,
      'longitude': longitude,
      'verificationPass': verificationPass,
      'notes': notes,
      'sanctionAmount': sanctionAmount,
      'bankVerified': bankVerified,
      'documentsVerified': documentsVerified,
      'referencesVerified': referencesVerified,
      'riskFlags': riskFlags,
      'bmRemarks': bmRemarks,
      'nameInBank': nameInBank,
    };
  }
}
