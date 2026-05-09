class CompanyInvitationModel {
  const CompanyInvitationModel({
    required this.id,
    required this.companyId,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedByProfileId,
    this.acceptedByProfileId,
    this.cancelledByProfileId,
    required this.expiresAt,
    required this.createdAt,
    this.acceptedAt,
    this.cancelledAt,
    required this.updatedAt,
    this.companyName,
    this.invitedByName,
    this.invitedByEmail,
  });

  final String id;
  final String companyId;
  final String email;
  final String role;
  final String status;
  final String invitedByProfileId;
  final String? acceptedByProfileId;
  final String? cancelledByProfileId;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? cancelledAt;
  final DateTime updatedAt;

  final String? companyName;
  final String? invitedByName;
  final String? invitedByEmail;

  factory CompanyInvitationModel.fromJson(Map<String, dynamic> json) {
    final companyJson =
        _mapOrNull(json['company']) ?? _mapOrNull(json['companies']);

    final invitedByProfileJson =
        _mapOrNull(json['invited_by_profile']) ?? _mapOrNull(json['profiles']);

    return CompanyInvitationModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      email: json['email'] as String,
      role: json['role'].toString(),
      status: json['status'].toString(),
      invitedByProfileId: json['invited_by_profile_id'] as String,
      acceptedByProfileId: json['accepted_by_profile_id'] as String?,
      cancelledByProfileId: json['cancelled_by_profile_id'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: _dateTimeOrNull(json['accepted_at']),
      cancelledAt: _dateTimeOrNull(json['cancelled_at']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      companyName: companyJson?['name'] as String?,
      invitedByName: invitedByProfileJson?['full_name'] as String?,
      invitedByEmail: invitedByProfileJson?['email'] as String?,
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
