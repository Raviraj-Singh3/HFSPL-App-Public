

class GetMemberPastVisitDetails {
  final List<Detail>? details;
  final List<History>? history;
  final List<String>? reasons;
  final Demand? demand;
  final LatestLocation? latestLocation;

  GetMemberPastVisitDetails({
    this.details,
    this.history,
    this.reasons,
    this.demand,
    this.latestLocation,
  });

  factory GetMemberPastVisitDetails.fromJson(Map<String, dynamic> json) {
    return GetMemberPastVisitDetails(
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => Detail.fromJson(e))
          .toList(),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => History.fromJson(e))
          .toList(),
      reasons: List<String>.from(json['reasons'] ?? []),
      demand: json['demand'] != null ? Demand.fromJson(json['demand']) : null,
      latestLocation: json['latestLocation'] != null ? LatestLocation.fromJson(json['latestLocation']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.map((e) => e.toJson()).toList(),
      'history': history?.map((e) => e.toJson()).toList(),
      'reasons': reasons,
      'demand': demand?.toJson(),
    };
  }
}

class Detail {
  final int? centerId;
  final int? clientId;
  final int? groupId;

  Detail({
    this.centerId,
    this.clientId,
    this.groupId,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      centerId: json['centerId'],
      clientId: json['clientId'],
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'clientId': clientId,
      'groupId': groupId,
    };
  }
}

class History {
  final String? cDate;
  final String? clientReason;
  final String? filepath;
  final int? id;
  final String? nextVisitDate;
  final String? observation;
  final String? visitedBy;
  final String? latitude;
  final String? longitude;

  History({
    this.cDate,
    this.clientReason,
    this.filepath,
    this.id,
    this.nextVisitDate,
    this.observation,
    this.visitedBy,
    this.latitude,
    this.longitude,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      cDate: json['CDate'],
      clientReason: json['ClientReason'],
      filepath: json['Filepath'],
      id: json['Id'],
      nextVisitDate: json['NextVisitDate'],
      observation: json['Observation'],
      visitedBy: json['VisitBy'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CDate': cDate,
      'ClientReason': clientReason,
      'Filepath': filepath,
      'Id': id,
      'NextVisitDate': nextVisitDate,
      'Observation': observation,
      'VisitBy': visitedBy,
      'Latitude': latitude,
      'Longitude': longitude,
      
    };
  }
}

class Demand {
  final String? bank;
  final int? clientId;
  final bool? clientPhotoEnable;
  final String? collectionDate;
  final double? disAmt;
  final String? disDate;
  final double? demand;
  final double? emi;
  final double? intRate;
  final int? installment;
  final double? interest;
  final String? loanNumber;
  final int? mid;
  final int? memberPhone1;
  final String? name;
  final double? overdue;
  final double? penalty;
  final double? principal;
  final String? relativeName;
  final int? shgId;

  Demand({
    this.bank,
    this.clientId,
    this.clientPhotoEnable,
    this.collectionDate,
    this.disAmt,
    this.disDate,
    this.demand,
    this.emi,
    this.intRate,
    this.installment,
    this.interest,
    this.loanNumber,
    this.mid,
    this.memberPhone1,
    this.name,
    this.overdue,
    this.penalty,
    this.principal,
    this.relativeName,
    this.shgId,
  });

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      bank: json['Bank'],
      clientId: json['Client_Id'],
      clientPhotoEnable: json['ClientPhotoEnable'],
      collectionDate: json['CollectionDate'],
      disAmt: (json['DIS_AMT'] as num?)?.toDouble(),
      disDate: json['DIS_DATE'],
      demand: (json['Demand'] as num?)?.toDouble(),
      emi: (json['Emi'] as num?)?.toDouble(),
      intRate: (json['INT_RATE'] as num?)?.toDouble(),
      installment: json['Installment'],
      interest: (json['Interest'] as num?)?.toDouble(),
      loanNumber: json['LoanNumber'],
      mid: json['M_id'],
      memberPhone1: json['MemberPhone1'],
      name: json['Name'],
      overdue: (json['Overdue'] as num?)?.toDouble(),
      penalty: (json['Penalty'] as num?)?.toDouble(),
      principal: (json['Principal'] as num?)?.toDouble(),
      relativeName: json['RelativeName'],
      shgId: json['shg_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Bank': bank,
      'Client_Id': clientId,
      'ClientPhotoEnable': clientPhotoEnable,
      'CollectionDate': collectionDate,
      'DIS_AMT': disAmt,
      'DIS_DATE': disDate,
      'Demand': demand,
      'Emi': emi,
      'INT_RATE': intRate,
      'Installment': installment,
      'Interest': interest,
      'LoanNumber': loanNumber,
      'M_id': mid,
      'MemberPhone1': memberPhone1,
      'Name': name,
      'Overdue': overdue,
      'Penalty': penalty,
      'Principal': principal,
      'RelativeName': relativeName,
      'shg_id': shgId,
    };
  }
}

class LatestLocation {
  final String? latitude;
  final String? longitude;
  

  LatestLocation({
    this.latitude,
    this.longitude,
  });

  factory LatestLocation.fromJson(Map<String, dynamic> json) {
    return LatestLocation(
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
      
    };
  }
}
