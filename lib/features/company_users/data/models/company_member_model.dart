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
    this.invitedByName,
    this.invitedByEmail,
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
  final String? invitedByName;
  final String? invitedByEmail;

  factory CompanyMemberModel.fromJson(Map<String, dynamic> json) {
    final memberProfileJson = json['member_profile'];
    final profilesJson = json['profiles'];

    final profileJson = memberProfileJson is Map<String, dynamic>
        ? memberProfileJson
        : profilesJson is Map<String, dynamic>
        ? profilesJson
        : null;

    final invitedByProfileJson = _mapOrNull(json['invited_by_profile']);

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
      fullName: _stringOrNull(json['full_name']) ??
          _stringOrNull(profileJson?['full_name']),
      email: _stringOrNull(json['email']) ?? _stringOrNull(profileJson?['email']),
      invitedByName: _stringOrNull(json['invited_by_name']) ??
          _stringOrNull(invitedByProfileJson?['full_name']),
      invitedByEmail: _stringOrNull(json['invited_by_email']) ??
          _stringOrNull(invitedByProfileJson?['email']),
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
