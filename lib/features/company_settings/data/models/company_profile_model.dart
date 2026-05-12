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
    );
  }

  static String _normalizeTimezone(dynamic value) {
    final timezone = value?.toString().trim();

    if (timezone == null || timezone.isEmpty) {
      return 'Asia/Dubai';
    }

    return timezone;
  }
}
