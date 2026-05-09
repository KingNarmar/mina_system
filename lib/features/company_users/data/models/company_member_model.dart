class CompanyMemberModel {
  const CompanyMemberModel({
    required this.id,
    required this.companyId,
    required this.profileId,
    required this.role,
    required this.status,
    this.joinedAt,
    this.invitedByProfileId,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.email,
  });

  final String id;
  final String companyId;
  final String profileId;
  final String role;
  final String status;
  final DateTime? joinedAt;
  final String? invitedByProfileId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? fullName;
  final String? email;

  factory CompanyMemberModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profiles'] as Map<String, dynamic>?;

    return CompanyMemberModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      profileId: json['profile_id'] as String,
      role: json['role'].toString(),
      status: json['status'].toString(),
      joinedAt: _dateTimeOrNull(json['joined_at']),
      invitedByProfileId: json['invited_by_profile_id'] as String?,
      createdAt: _dateTimeOrNull(json['created_at']),
      updatedAt: _dateTimeOrNull(json['updated_at']),
      fullName: profileJson?['full_name'] as String?,
      email: profileJson?['email'] as String?,
    );
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
