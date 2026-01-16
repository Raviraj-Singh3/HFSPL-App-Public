class UserRoleFlags {
  final bool isFe;
  final bool isOtherFieldMember;
  final bool isBM_BCM;
  final bool isTaskForce;
  final bool isOdOfficer;
  final bool isOtherStaff;
  final bool isTelecaller;

  UserRoleFlags({
    required this.isFe,
    required this.isOtherFieldMember,
    required this.isBM_BCM,
    required this.isTaskForce,
    required this.isOdOfficer,
    required this.isOtherStaff,
    required this.isTelecaller,
  });

  factory UserRoleFlags.fromJson(Map<String, dynamic> json) {
    return UserRoleFlags(
      isFe: json['isFe'] ?? false,
      isOtherFieldMember: json['isOtherFieldMember'] ?? false,
      isBM_BCM: json['isBM_BCM'] ?? false,
      isTaskForce: json['isTaskForce'] ?? false,
      isOdOfficer: json['isOdOfficer'] ?? false,
      isOtherStaff: json['isOtherStaff'] ?? false,
      isTelecaller: json['isTelecaller'] ?? false,
    );
  }
}
