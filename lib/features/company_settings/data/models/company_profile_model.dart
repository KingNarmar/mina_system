class CompanyProfileModel {
  const CompanyProfileModel({
    required this.id,
    required this.name,
    this.tradeName,
    this.legalName,
    this.tradeLicenseNo,
    this.taxRegistrationNo,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.logoPath,
    this.timezone = 'Asia/Dubai',
    this.createdByProfileId,
    this.updatedByProfileId,
    this.createdByProfileName,
    this.createdByProfileEmail,
    this.updatedByProfileName,
    this.updatedByProfileEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? tradeName;
  final String? legalName;
  final String? tradeLicenseNo;
  final String? taxRegistrationNo;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoPath;
  final String timezone;
  final String? createdByProfileId;
  final String? updatedByProfileId;
  final String? createdByProfileName;
  final String? createdByProfileEmail;
  final String? updatedByProfileName;
  final String? updatedByProfileEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get createdByDisplayName {
    return _resolveProfileDisplayName(
      name: createdByProfileName,
      email: createdByProfileEmail,
    );
  }

  String get updatedByDisplayName {
    return _resolveProfileDisplayName(
      name: updatedByProfileName,
      email: updatedByProfileEmail,
    );
  }

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tradeName: json['trade_name'] as String?,
      legalName: json['legal_name'] as String?,
      tradeLicenseNo: json['trade_license_no'] as String?,
      taxRegistrationNo: json['tax_registration_no'] as String?,
      addressLine1: json['address_line_1'] as String?,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoPath: json['logo_path'] as String?,
      timezone: _normalizeTimezone(json['timezone']),
      createdByProfileId: json['created_by_profile_id'] as String?,
      updatedByProfileId: json['updated_by_profile_id'] as String?,
      createdByProfileName: _readRelatedProfileValue(
        json: json,
        directKey: 'created_by_profile_name',
        relationKey: 'created_by_profile',
        fieldKey: 'full_name',
      ),
      createdByProfileEmail: _readRelatedProfileValue(
        json: json,
        directKey: 'created_by_profile_email',
        relationKey: 'created_by_profile',
        fieldKey: 'email',
      ),
      updatedByProfileName: _readRelatedProfileValue(
        json: json,
        directKey: 'updated_by_profile_name',
        relationKey: 'updated_by_profile',
        fieldKey: 'full_name',
      ),
      updatedByProfileEmail: _readRelatedProfileValue(
        json: json,
        directKey: 'updated_by_profile_email',
        relationKey: 'updated_by_profile',
        fieldKey: 'email',
      ),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name.trim(),
      'trade_name': tradeName?.trim(),
      'legal_name': legalName?.trim(),
      'trade_license_no': tradeLicenseNo?.trim(),
      'tax_registration_no': taxRegistrationNo?.trim(),
      'address_line_1': addressLine1?.trim(),
      'address_line_2': addressLine2?.trim(),
      'city': city?.trim(),
      'country': country?.trim(),
      'phone': phone?.trim(),
      'email': email?.trim(),
      'website': website?.trim(),
      'logo_path': logoPath?.trim(),
      'timezone': _normalizeTimezone(timezone),
    };
  }

  CompanyProfileModel copyWith({
    String? id,
    String? name,
    String? tradeName,
    String? legalName,
    String? tradeLicenseNo,
    String? taxRegistrationNo,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
    String? timezone,
    String? createdByProfileId,
    String? updatedByProfileId,
    String? createdByProfileName,
    String? createdByProfileEmail,
    String? updatedByProfileName,
    String? updatedByProfileEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tradeName: tradeName ?? this.tradeName,
      legalName: legalName ?? this.legalName,
      tradeLicenseNo: tradeLicenseNo ?? this.tradeLicenseNo,
      taxRegistrationNo: taxRegistrationNo ?? this.taxRegistrationNo,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoPath: logoPath ?? this.logoPath,
      timezone: timezone ?? this.timezone,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      updatedByProfileId: updatedByProfileId ?? this.updatedByProfileId,
      createdByProfileName: createdByProfileName ?? this.createdByProfileName,
      createdByProfileEmail:
          createdByProfileEmail ?? this.createdByProfileEmail,
      updatedByProfileName: updatedByProfileName ?? this.updatedByProfileName,
      updatedByProfileEmail:
          updatedByProfileEmail ?? this.updatedByProfileEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _normalizeTimezone(dynamic value) {
    final timezone = value?.toString().trim();

    if (timezone == null || timezone.isEmpty) {
      return 'Asia/Dubai';
    }

    return timezone;
  }

  static String? _readRelatedProfileValue({
    required Map<String, dynamic> json,
    required String directKey,
    required String relationKey,
    required String fieldKey,
  }) {
    final directValue = json[directKey];

    if (directValue is String) {
      return directValue;
    }

    final relationValue = json[relationKey];

    if (relationValue is Map<String, dynamic>) {
      return relationValue[fieldKey] as String?;
    }

    if (relationValue is Map) {
      return relationValue[fieldKey]?.toString();
    }

    return null;
  }

  static String _resolveProfileDisplayName({
    required String? name,
    required String? email,
  }) {
    final cleanName = name?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      return cleanName;
    }

    final cleanEmail = email?.trim();

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail;
    }

    return 'Unknown User';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value.toString());
  }
}
