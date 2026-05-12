class CreateCompanyRequest {
  const CreateCompanyRequest({
    required this.companyName,
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

  final String companyName;
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

  Map<String, dynamic> toJson() {
    return {
      'p_name': companyName.trim(),
      'p_trade_name': _emptyToNull(tradeName),
      'p_legal_name': _emptyToNull(legalName),
      'p_trade_license_no': _emptyToNull(tradeLicenseNo),
      'p_tax_registration_no': _emptyToNull(taxRegistrationNo),
      'p_address_line_1': _emptyToNull(addressLine1),
      'p_address_line_2': _emptyToNull(addressLine2),
      'p_city': _emptyToNull(city),
      'p_country': _emptyToNull(country),
      'p_phone': _emptyToNull(phone),
      'p_email': _emptyToNull(email),
      'p_website': _emptyToNull(website),
      'p_logo_path': _emptyToNull(logoPath),
      'p_timezone': _normalizeTimezone(timezone),
    };
  }

  static String? _emptyToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  static String _normalizeTimezone(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Asia/Dubai';
    }

    return trimmedValue;
  }
}
